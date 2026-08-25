import json
import os
import sys
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parent.parent / "lambda"))
os.environ.setdefault("BUCKET_NAME", "test-bucket")

from handler import handler


def test_handler_default_name():
    with patch("handler.boto3.client") as mock_client:
        mock_client.return_value.list_objects_v2.return_value = {"Contents": [{}, {}, {}]}
        response = handler({}, None)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["message"] == "hello, world"
    assert body["file_count"] == 3


def test_handler_with_name():
    with patch("handler.boto3.client") as mock_client:
        mock_client.return_value.list_objects_v2.return_value = {"Contents": [{}]}
        event = {"queryStringParameters": {"name": "roots"}}
        response = handler(event, None)
    body = json.loads(response["body"])
    assert body["message"] == "hello, roots"
    assert body["file_count"] == 1


def test_handler_empty_bucket():
    # A bucket with no objects has no "Contents" key at all in the response —
    # not an empty list. This is the one that catches a naive ["Contents"].
    with patch("handler.boto3.client") as mock_client:
        mock_client.return_value.list_objects_v2.return_value = {}
        response = handler({}, None)
    assert json.loads(response["body"])["file_count"] == 0
