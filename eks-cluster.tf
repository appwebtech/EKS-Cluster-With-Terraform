
provider "kubernetes" {
 # load_config_file       = "false" (Removed in [V2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/v2-upgrade-guide#changes-to-kubernetes-credentials-supplied-in-the-provider-block))
  host                   = data.aws_eks_cluster.myapp-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.myapp-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.20.0"

  cluster_name    = "myapp-eks-cluster"
  cluster_version = "1.17"
  subnets         = module.myapp-vpc.private_subnets
  vpc_id          = module.myapp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }

  worker_groups = [
    {
      instance_type        = "t2.small"
      name                 = "worker-group-1"
      asg_desired_capacity = 2
    },
    {
      instance_type        = "t2.medium"
      name                 = "worker-group-2"
      asg_desired_capacity = 1
    }
  ]

}