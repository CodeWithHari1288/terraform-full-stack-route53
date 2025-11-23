# Terraform Full Stack Route53 Demo

This repo contains a self-contained Terraform **learning stack**:

- Custom VPC (public + private subnets, IGW, NAT, NACLs, Security Groups)
- Transit Gateway + VPC attachment
- EC2 Launch Template + Auto Scaling Group (simple HTTP server)
- API Gateway REST API with `/hello`
- S3 static hello website + CloudFront
- Route53 hosted zone + `www` A-record alias to CloudFront
- CodeCommit repository
- CodeDeploy application + deployment group (targets ASG)
- CodePipeline (CodeCommit → CodeDeploy)

## How to use

```bash
cd learning/full-stack-route53

terraform init
terraform plan
terraform apply
```

### Important

1. Update `var.domain_name` in `variables.tf` to a domain you own, or override:

```bash
terraform apply -var="domain_name=yourdomain.com"
```

2. After apply, go to your **domain registrar** and update the domain's **nameservers** to the NS records from the Route53 hosted zone (`aws_route53_zone.main`).

3. This is a **learning stack** – it will create chargeable resources:
   - NAT Gateway
   - EC2 instances
   - CloudFront
   - API Gateway, etc.

Destroy it when done:

```bash
terraform destroy
```
