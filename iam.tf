resource "aws_iam_role" "aws_s3_csi_driver_role" {
  name = "${var.jit_name_prefix}-s3-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:s3-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_csi_driver_policy" {
  name = "s3-csi-driver-inline-policy"
  role = aws_iam_role.aws_s3_csi_driver_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = module.s3_bucket.s3_bucket_arn,
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        Resource = "${module.s3_bucket.s3_bucket_arn}/*"
      }
    ]
  })
}
