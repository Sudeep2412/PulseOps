resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "06d927fecd0a84aeba28aad1d808139470fe95c3",
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f8d264fcd9"
  ]

  tags = {}

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "github_actions_ecr" {
  name        = "github-actions-pulseops-ecr"
  description = "Least-privilege role for GitHub Actions to publish images to PulseOps ECR"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = [
              "repo:Sudeep2412@143870213/PulseOps@1441664918:ref:refs/heads/main",
              "repo:Sudeep2412/PulseOps:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {}

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy" "ecr_publish" {
  name = "PulseOpsECRPublishPolicy"
  role = aws_iam_role.github_actions_ecr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryPushAndVerify"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages"
        ]
        Resource = var.ecr_repository_arn
      },
      {
        Sid    = "SSMSendDeploymentCommand"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand"
        ]
        Resource = [
          "arn:aws:ssm:us-east-1::document/AWS-RunShellScript",
          "arn:aws:ec2:us-east-1:512888109658:instance/i-05e6553f01eb76141"
        ]
      },
      {
        Sid    = "SSMGetDeploymentCommandStatus"
        Effect = "Allow"
        Action = [
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations"
        ]
        Resource = "*"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}
