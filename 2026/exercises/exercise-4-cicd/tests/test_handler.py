import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "lambda"))

from handler import handler


def test_handler_default_name():
    response = handler({}, None)
    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == {"message": "hello, world"}


def test_handler_with_name():
    event = {"queryStringParameters": {"name": "roots"}}
    response = handler(event, None)
    assert json.loads(response["body"]) == {"message": "hello, roots"}
