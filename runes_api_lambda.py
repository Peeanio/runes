"""lambda function to interact with dynamodb for runes app, intended as api"""
import random
import boto3

def lambda_handler(event, context):
    """lambda entry point"""
    print("hellow world")
    client = boto3.client('dynamodb')
    response = client.scan(TableName='rune_table')
    print(response)
    picked_rune_number = random.randint(0, (len(response['Items']) - 1))
    return response['Items'][picked_rune_number]
