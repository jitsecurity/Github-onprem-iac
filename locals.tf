locals {
  vpc_cidr = "10.10.0.0/16"
  azs      = slice(data.aws_availability_zones.this.names, 0, 3)

  tags = {
    Service     = "jit-agent-service"
    Environment = "poc"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "cloudflare_zone" "this" {
  zone_id = var.cloudflare_zone_id
}

data "aws_availability_zones" "this" {}
