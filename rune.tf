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

data "aws_cloudformation_export" "api_rune" {
  name = "ApiUri"
}

data "template_file" "index" {
  template = "${file("${path.module}/index.tftpl")}"
  vars = {
    api_uri = data.aws_cloudformation_export.api_rune.value 
  }
}

resource "aws_s3_object" "index" {
  bucket = "runes-static-website"
  content_type = "text/html"
  key = "index.html"
  content = data.template_file.index.rendered
}
