data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "backstage_eks_policy" {
  name        = "BackstageEKSPolicy"
  description = "Policy for Backstage to access EKS Clusters"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "eks:*",
#         Action = "eks:DescribeCluster",
        Resource = "*"
      }
    ]
  })
}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = local.cluster_name
}

locals {
  oidc_provider = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_iam_role" "backstage_eks_role" {
  name = "BackstageEKSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:sub" = "system:serviceaccount:backstage:backstage-service-account" # Adjust this based on your service account and namespace
          }
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "backstage_eks_policy_attach" {
  role       = aws_iam_role.backstage_eks_role.name
  policy_arn = aws_iam_policy.backstage_eks_policy.arn
}


module "eks_auth" {
  source = "aidanmelen/eks-auth/aws"
  eks    = module.eks

  map_roles = [
    {
      rolearn  = aws_iam_role.backstage_eks_role.arn
      username = "backstage-admin"
      groups   = ["system:masters"]
    },
  ]
}