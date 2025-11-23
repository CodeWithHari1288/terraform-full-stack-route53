resource "aws_codecommit_repository" "app_repo" {
  repository_name = "demo-app-repo"
  description     = "Demo app for CodeDeploy"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "demo-codepipeline-artifacts-${var.region}"
}

resource "aws_iam_role" "codedeploy_role" {
  name = "demo-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "ec2_app" {
  name             = "demo-ec2-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "ec2_dg" {
  app_name              = aws_codedeploy_app.ec2_app.name
  deployment_group_name = "demo-ec2-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = [aws_autoscaling_group.web_asg.name]

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "demo-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "demo-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:*"
        ]
        Resource = [aws_codecommit_repository.app_repo.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codepipeline" "app_pipeline" {
  name     = "demo-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        RepositoryName = aws_codecommit_repository.app_repo.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["SourceOutput"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.ec2_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.ec2_dg.deployment_group_name
      }
    }
  }
}
