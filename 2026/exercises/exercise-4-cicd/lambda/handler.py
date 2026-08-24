import json


def handler(event, context):
    name = event.get("queryStringParameters", {}).get("name", "world") if event.get("queryStringParameters") else "world"
    return {
        "statusCode": 200,
        "body": json.dumps({"message": f"hello, {name}"}),
    }
