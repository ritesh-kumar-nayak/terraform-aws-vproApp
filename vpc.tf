module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = var.VPC_NAME     #please refer the terraform registry of  https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v5.1.2/examples/complete/main.tf
    cidr = var.VPC_CIDER
    azs = [var.ZONE-1, var.ZONE-2, var.ZONE-3]
    public_subnets = [var.PubSub1_CIDER, var.PubSub2_CIDER, var.PubSub3_CIDER]
    enable_nat_gateway = true
    single_nat_gateway = true # as we have multiple private subnet it will create multiple NAT gateway which will be expenssive so, we are adding this attribute.
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        terraform = "True"
        Environment = "Prod"
    }

    vpc_tags = {
        Name=var.VPC_NAME
    }

  
}