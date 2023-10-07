resource "aws_security_group" "vpro-beanstalk-elb-sg" {
  name        = "vpro-beanstalk-elb-sg"
  description = "Security grup for Beanstalk Elastic Loadbalancer"
  #security group has to be a part of VPC so VPC_ID is mandatory
  vpc_id = module.vpc.vpc_id

  egress { # Outbound Rule
    from_port   = 0
    protocol    = "-1" # -1 means all the protocol
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] # allow outbound to go anywhere
  }

  ingress {
    from_port   = 80    # Allowing access from port 80
    protocol    = "tcp" # here the protocol is only tcp
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_security_group" "vpro-bastionHost-sg" {
  name        = "vpro-bastionHost-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Bastion host"

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [var.MY_IP]
  }


}

# Now we'll create the Security Group for EC2 instance in our Beanstalk Environment
# This security group will be attached to the EC2 instances created by beanstalk3

resource "aws_security_group" "vpro-prod-sg" {
  name        = "vpro-prod-sg"
  description = "Security group for Beanstalk instances"
  vpc_id      = module.vpc.vpc_id

  egress { # Outbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # here we are allowing only the bastion Host to access the instances using port 22(SSH) so, we are allowing the traffic from bastionHost security group here

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpro-bastionHost-sg.id] # So, only the bastionHost has the access to beanstalk EC2 instances at private port 22 and as we know bastion host can only be accessed from "MyIP" so we are having a tight control over security
  }
}

# Now we'll create the security group for our backend services such as RDS, Elasticache, ActiveMQ 

resource "aws_security_group" "vpro-backend-sg" {

  name        = "vpro-backend-sg"
  description = "Securiy group for backend services such as RDS, ActiveMQ and Elasticache "
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Here we are allowing access to all the protocol from all the ports.
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpro-prod-sg.id] # Beanstalk instances where our application will run can access the backends
  }

}

# Now as the backend security group has been created, the bakend services should be able to interact with each other.
# To make them interact with each other, we have to allow the "vpro-backend-sg" to access itself (vpro-backend-sg)
# To make it happen we'll use "aws_security_group_rule" resource

resource "aws_security_group_rule" "security-group-allow-itself" {

  type                     = "ingress" # Updating the inbound rule so type is ingress
  from_port                = 0
  to_port                  = 65535 # To all the ports
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpro-backend-sg.id # id of the security group that you want to update
  source_security_group_id = aws_security_group.vpro-backend-sg.id # From which SG id you want to allow the access
  # Here we want to allow backend sg to acces backend sg itself hence security_group_id & source_security_group_id
}