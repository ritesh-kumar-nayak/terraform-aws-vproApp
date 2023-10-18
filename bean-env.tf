resource "aws_elastic_beanstalk_environment" "Vpro-bean-prod" {
  name                = "Vpro-bean-prod"
  application         = aws_elastic_beanstalk_application.vpro-prod.name
  solution_stack_name = "64bit Amazon Linux 2 v4.3.12 running Tomcat 8.5 Corretto 11" # There are multiple solution stacks such as Tomcat, Docker, Go, Node.JS etc. that we can find on Documentation. Our prefered is Tomcat
  cname_prefix        = "Vpro-bean-prod-domain"                                       # this will be the url

  # Elastic Beanstalk has a lot of settings for best use, now we'll define all the settings
  setting { # setting { ... }: This block is configuring a setting for the Elastic Beanstalk environment.

    name      = "VPCId"
    namespace = "aws:ec2:vpc" # We are putting the Beanstalk inside the VPC 
    value     = module.vpc.vpc_id

  }

  # Creating Elastic Beanstalk Role  https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-autoscalinglaunchconfiguration
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  # Associating public IP address https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-ec2vpc
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  # Now we are putting the EC2 instances in private subnet but our LoabBalancers will be in Public subnet
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [module.vpc.private_subnets[0]], [module.vpc.private_subnets[1]], [module.vpc.private_subnets[2]]) # join is a functuon that can join lists into a string
    # Here we are joining the subnets in a list separated by comma
    # There are lot of built-in terraform functions available.
  }

  # EC2 instances in private subnet but our LoabBalancers will be in Public subnet

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [module.vpc.public_subnets[0]], [module.vpc.public_subnets[1]], [module.vpc.public_subnets[2]]) # this entire thing will be converted to a string
  }

  # Defining the instance type that will be lunched by Autoscalling group
  setting {
    namespace = "aws:autoscaling:launchconfiguration" # this is to create lunch configuration that defines the template of EC2 instance
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.Vprofile-key.key_name
  }

  setting {
    namespace = "aws:autoscaling:asg" # this is to create auto scalling group
    name      = "Availability Zones"
    value     = "Any 3"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize" # defining maximum EC2 instance that can be launched
    value     = "8"
  }

  # Setting Environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "environment"
    value     = "Prod"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LOGGING_APPENDER"
    value     = "GRAYLOG"
  }

  # Setting for monitoring the health of EC2 instance
  setting {
    namespace = "elasticbeanstalk:healthreporting:system" # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-elasticbeanstalkhealthreporting
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = "1"
  }

  setting {
    namespace = "aws:elb:loadbalancer" # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-elbloadbalancer
    name      = "CrossZone"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled" #This option is only applicable to environments with an application load balancer.
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Fixed"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.vpro-prod-sg.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.vpro-beanstalk-elb-sg.id
  }

  # So now we are done with the settings but, the beanstalk depends on the security groups where it can attach them. So the priority is to create the Secruity group first.
  #  All the resources that are placed in depends_on will be created first then only it will move to other resources.

  depends_on = [aws_security_group.vpro-beanstalk-elb-sg, aws_security_group.vpro-prod-sg]

}