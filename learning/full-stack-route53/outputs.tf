output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}

output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.demo_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.demo_stage.stage_name}/hello"
}

output "cloudfront_static_domain" {
  value = aws_cloudfront_distribution.static_cdn.domain_name
}

output "static_site_url" {
  value = "https://www.${var.domain_name}"
}
