resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-role"

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
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:mahmoud/AWS-Two-Tier-Architecture:*" # Replace 'mahmoud/AWS-Two-Tier-Architecture' with your actual GitHub username/repo
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_terraform_policy" {
  name = "github-actions-terraform-policy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageTwoTierInfraServices"
        Effect = "Allow"
        Action = [
          "ec2:AllocateAddress",
          "ec2:AssociateRouteTable",
          "ec2:AttachInternetGateway",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:Create*",
          "ec2:Delete*",
          "ec2:Describe*",
          "ec2:DisassociateRouteTable",
          "ec2:Modify*",
          "ec2:ReleaseAddress",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:Create*",
          "elasticloadbalancing:Delete*",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:Modify*",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:Set*",
          "autoscaling:Attach*",
          "autoscaling:Create*",
          "autoscaling:Delete*",
          "autoscaling:Describe*",
          "autoscaling:Detach*",
          "autoscaling:Put*",
          "autoscaling:ResumeProcesses",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:SuspendProcesses",
          "autoscaling:UpdateAutoScalingGroup",
          "rds:AddTagsToResource",
          "rds:Create*",
          "rds:Delete*",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "rds:Modify*",
          "rds:RemoveTagsFromResource",
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "wafv2:AssociateWebACL",
          "wafv2:Create*",
          "wafv2:Delete*",
          "wafv2:DisassociateWebACL",
          "wafv2:Get*",
          "wafv2:List*",
          "wafv2:TagResource",
          "wafv2:UntagResource",
          "wafv2:Update*",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DisableAlarmActions",
          "cloudwatch:EnableAlarmActions",
          "cloudwatch:GetDashboard",
          "cloudwatch:ListDashboards",
          "cloudwatch:ListMetrics",
          "cloudwatch:ListTagsForResource",
          "cloudwatch:PutDashboard",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:TagResource",
          "cloudwatch:UntagResource",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:DeleteRetentionPolicy",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:ListTagsForResource",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:UntagResource",
          "sns:CreateTopic",
          "sns:DeleteTopic",
          "sns:GetTopicAttributes",
          "sns:ListSubscriptionsByTopic",
          "sns:ListTagsForResource",
          "sns:ListTopics",
          "sns:SetTopicAttributes",
          "sns:Subscribe",
          "sns:TagResource",
          "sns:UntagResource",
          "sns:Unsubscribe",
          "ssm:AddTagsToResource",
          "ssm:DeleteParameter",
          "ssm:DeleteParameters",
          "ssm:DescribeParameters",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:ListTagsForResource",
          "ssm:PutParameter",
          "ssm:RemoveTagsFromResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "StateBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::two-tier-tf-state-bucket-tf"
      },
      {
        Sid    = "StateObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::two-tier-tf-state-bucket-tf/*"
      },
      {
        Sid    = "AlbLogsBucketManagement"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
          "s3:GetBucketTagging",
          "s3:ListBucket",
          "s3:PutBucketPolicy",
          "s3:PutBucketTagging",
          "s3:DeleteBucketPolicy",
          "s3:DeleteBucketTagging",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::two-tier-alb-logs-bucket",
          "arn:aws:s3:::two-tier-alb-logs-bucket/*"
        ]
      },
      {
        Sid    = "StateLockTableAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/two-tier-tf-locks"
      },
      {
        Sid    = "IamManagementForThisStack"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:UntagInstanceProfile",
          "iam:ListInstanceProfilesForRole",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:AddClientIDToOpenIDConnectProvider",
          "iam:RemoveClientIDFromOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:ListOpenIDConnectProviders",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      },
      {
        Sid    = "PassEc2RolesOnly"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::*:role/two-tier-*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      }
    ]
  })
}
