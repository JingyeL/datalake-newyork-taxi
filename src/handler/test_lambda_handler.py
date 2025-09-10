import json
import pytest
from unittest.mock import patch, MagicMock

# Import your Lambda handler - adjust the import path as needed
# from lambda_handler import handler


# Define test fixture for standard event
@pytest.fixture
def apigw_event():
    """Generates API GW Event"""
    return {
        "body": json.dumps({"test": "body"}),
        "resource": "/{proxy+}",
        "requestContext": {
            "resourceId": "123456",
            "apiId": "1234567890",
            "resourcePath": "/{proxy+}",
            "httpMethod": "POST",
            "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef",
            "accountId": "123456789012",
            "identity": {
                "apiKey": "",
                "userArn": "",
                "cognitoAuthenticationType": "",
                "caller": "",
                "userAgent": "Custom User Agent String",
                "user": "",
                "cognitoIdentityPoolId": "",
                "cognitoIdentityId": "",
                "cognitoAuthenticationProvider": "",
                "sourceIp": "127.0.0.1",
                "accountId": "",
            },
            "stage": "prod",
        },
        "queryStringParameters": {"foo": "bar"},
        "headers": {
            "Via": "1.1 08f323deadbeefa7af34d5feb414ce27.cloudfront.net (CloudFront)",
            "Accept-Language": "en-US,en;q=0.8",
            "CloudFront-Is-Desktop-Viewer": "true",
            "CloudFront-Is-SmartTV-Viewer": "false",
            "CloudFront-Is-Mobile-Viewer": "false",
            "X-Forwarded-For": "127.0.0.1, 127.0.0.2",
            "CloudFront-Viewer-Country": "US",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Upgrade-Insecure-Requests": "1",
            "X-Forwarded-Port": "443",
            "Host": "1234567890.execute-api.us-east-1.amazonaws.com",
            "X-Forwarded-Proto": "https",
            "X-Amz-Cf-Id": "aaaaaaaaaae3VYQb9jd-nvCd-de396Uhbp027Y2JvkCPNLmGJHqlaA==",
            "CloudFront-Is-Tablet-Viewer": "false",
            "Cache-Control": "max-age=0",
            "User-Agent": "Custom User Agent String",
            "CloudFront-Forwarded-Proto": "https",
            "Accept-Encoding": "gzip, deflate, sdch",
        },
        "pathParameters": {"proxy": "/path/to/resource"},
        "httpMethod": "POST",
        "stageVariables": {"baz": "qux"},
        "path": "/path/to/resource",
    }


def test_lambda_handler(apigw_event):
    """Test that the Lambda handler responds correctly"""
    # Uncomment and adjust once you have your actual handler imported
    # response = handler(apigw_event, {})

    # Assert response is as expected
    # assert response["statusCode"] == 200
    # assert "body" in response
    # response_body = json.loads(response["body"])
    # assert response_body["message"] == "hello world"


@patch("src.handler.lambda_handler.lambda_handler")
def test_lambda_handler_with_mock(mock_dependency, apigw_event):
    """Test Lambda handler with mocked dependencies"""
    # Set up your mock
    mock_dependency.return_value = "mocked_value"

    # Call the handler
    # response = handler(apigw_event, {})

    # Assertions
    # assert response["statusCode"] == 200
    # mock_dependency.assert_called_once()
