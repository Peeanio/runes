"""lambda function to interact with dynamodb for runes app, intended as api"""
import json
import boto3
import random

def lambda_handler(event, context):
    """lambda entry point"""
    print("hellow world")
    client = boto3.Client('dynamodb')
    response = client.scan(TableName='rune_table')
    picked_runeNumber = random.randint(0, (len(response['Items']) - 1) 
    print(response['Items'][picked_runeNumber]['Description']['S'])
    

def checkPut():
    """checks for and puts entry"""
    response = client.get_item(TableName='rune_table', Key={'runeName': { 'S': 'Strength'}})
    if "Item" in response.keys():
        print("key found")
    else:
        print("adding key, not found")
        response = client.put_item(TableName='rune_table', Item={'runeName': {'S': 'Strengt'}, 'Description': {'S': 'Strengtd'}, 'Number': {'N': "1"}})
