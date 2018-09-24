provider "aws" {
  region     = "us-east-1"
}

resource "aws_iam_role" "build" {
  name = "slow-build"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "build" {
  role = "${aws_iam_role.build.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

resource "aws_ecr_repository" "environments" {
  name = "build-image"
}

resource "aws_ecr_repository_policy" "environments" {
  repository = "${aws_ecr_repository.environments.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodeBuildAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"  
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
EOF
}

output "repository_url" {
  value = "${aws_ecr_repository.environments.repository_url}"
}

resource "aws_codebuild_project" "build" {
  name          = "slow-build"
  description   = "A slow building CodeBuild project."
  build_timeout = "5"
  service_role  = "${aws_iam_role.build.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/FindAPattern/cloud-build-custom-environment.git"
    git_clone_depth = 1
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${aws_ecr_repository.environments.repository_url}:latest"
    type         = "LINUX_CONTAINER"
  }
}

