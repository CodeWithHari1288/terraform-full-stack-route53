resource "aws_api_gateway_rest_api" "demo_api" {
  name        = "demo-api"
  description = "Simple hello API"
}

resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.demo_api.id
  parent_id   = aws_api_gateway_rest_api.demo_api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.demo_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id = aws_api_gateway_rest_api.demo_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "hello_200" {
  rest_api_id = aws_api_gateway_rest_api.demo_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "hello_integration_200" {
  rest_api_id = aws_api_gateway_rest_api.demo_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = aws_api_gateway_method_response.hello_200.status_code

  response_templates = {
    "application/json" = "{\"message\": \"Hello from API Gateway\"}"
  }
}

resource "aws_api_gateway_deployment" "demo_deployment" {
  rest_api_id = aws_api_gateway_rest_api.demo_api.id
  depends_on  = [aws_api_gateway_integration.hello_integration]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "demo_stage" {
  rest_api_id   = aws_api_gateway_rest_api.demo_api.id
  deployment_id = aws_api_gateway_deployment.demo_deployment.id
  stage_name    = "prod"
}
