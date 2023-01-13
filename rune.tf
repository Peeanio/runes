terraform { 
  required_providers {
   aws = { 
     source = "hashicorp/aws"
     version = "~> 4.0"
   }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "lambda" {
  bucket = "runes-app-lambda"
}

data "archive_file" "lambda" {
  type = "zip"
  source_file = "runes_api_lambda.py"
  output_path = "runes_api_lambda.zip"
}

resource "aws_s3_object" "lambda" {
  depends_on = [
    data.archive_file.lambda,
    resource.aws_s3_bucket.lambda
  ]
  bucket = "runes-app-lambda"
  content_type = "application/zip"
  key = "runes_api_lambda.zip"
  source = "runes_api_lambda.zip"
}

resource "aws_lambda_function" "lambda_rune" {
  depends_on = [
    aws_s3_object.lambda
  ]
  function_name =  "runes_api_lambda"
  handler = "runes_api_lambda.lambda_handler"
  runtime = "python3.9"
  s3_bucket = "runes-app-lambda"
  s3_key = "runes_api_lambda.zip"
  description = "get rune data from dynamodb"
  memory_size = 128
  timeout = 100
  role = resource.aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "rune_lambda_role"
  assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }]
  })
  path = "/"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "rune_lambda_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["dynamodb:*"]
      Effect = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_dynamodb_table" "dynamodb_rune_table" {
  name = "rune_table"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "runeId"
    type = "N"
  }
  hash_key = "runeId"
}

resource "aws_lambda_permission" "api_lambda_invoke" {
  function_name = resource.aws_lambda_function.lambda_rune.function_name
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.runes_api.execution_arn}/*/*/*"
}
 
resource "aws_apigatewayv2_api" "runes_api" {
  name = "runes"
  description = "REST api for runes application"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "runes_integration" {
  api_id = aws_apigatewayv2_api.runes_api.id
  integration_type = "AWS_PROXY"
  payload_format_version = "2.0"
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda_rune.invoke_arn
}

resource "aws_apigatewayv2_route" "runes_route" {
  api_id = aws_apigatewayv2_api.runes_api.id
  route_key = "GET /api/v1/rune"
  target = "integrations/${aws_apigatewayv2_integration.runes_integration.id}"
}

resource "aws_apigatewayv2_stage" "runes_stage" {
  api_id = aws_apigatewayv2_api.runes_api.id
  name = "$default"
  auto_deploy = true
  default_route_settings {
    throttling_rate_limit = 100
    throttling_burst_limit = 100
  }
}

resource "aws_s3_bucket" "static_site_storage" {
  bucket = "runes-static-website"
}

resource "aws_s3_bucket_acl" "static_acl" {
  bucket = aws_s3_bucket.static_site_storage.id
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_site_storage.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "static-policy" {
  bucket = aws_s3_bucket.static_site_storage.id
  policy = jsonencode({
     Version = "2012-10-17"
     Statement = [{
       Sid = "PublicReadGetObject"
       Effect = "Allow"
       Resource = "${aws_s3_bucket.static_site_storage.arn}/*"
       Principal = "*"
       Action = "s3:GetObject"
     }]
  })
}

data "template_file" "index" {
  template = "${file("${path.module}/index.tftpl")}"
  vars = {
    api_uri = aws_apigatewayv2_api.runes_api.api_endpoint
  }
}

resource "aws_s3_object" "index" {
  depends_on = [
    aws_s3_bucket.static_site_storage
  ]
  bucket = "runes-static-website"
  content_type = "text/html"
  key = "index.html"
  content = data.template_file.index.rendered
}
