resource "aws_db_subnet_group" "vpro-db-subnet-group" {
    name = "main"
    subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
    # RDS will be in the subnet groups which is part of 3 subnet ids or collection of 3 subnet ids

    tags = {
        Name= "Subnet Group for RDS"
    }
  
}

resource "aws_elasticache_subnet_group" "vpro-elasticache-subnet-group" {
    name = "Vpro-ecache-subnetgroup"
    subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
    # ElasticCache will be in the subnet groups which is part of 3 subnet ids or collection of 3 subnet ids
    tags = {
      Name= "Subnet Group for Elasticache"
    }
}

# DB Instance for RDS
resource "aws_db_instance" "vpro-rds" {

    allocated_storage = 20
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.6.34"
    instance_class = "db.t2.micro"
    name = var.DB_NAME
    username = var.DB_USER
    password = var.DB_PASSWORD
    parameter_group_name = "default.mysql5.6"
    multi_az = false                          # keep it true for high avalability
    publicly_accessible = false               # We do not want it to be accessible from public as it will be accessible by Elastic Beanstalk
    skip_final_snapshot = true                # This will keep creating snapshots of the RDS that can be used while recovering the if deleted which will be very much expenssive for us. But it is recomended to keep it "true" for production grade infra
    db_subnet_group_name = aws_db_subnet_group.vpro-db-subnet-group.name
    vpc_security_group_ids = [aws_security_group.vpro-backend-sg.id]
  
}

# AWS Elasticache(Memcahced) for DB caching
resource "aws_elasticache_cluster" "vpro-elasticache" {
    cluster_id = "vpro-elasticache"
    engine = "memcached"
    node_type = "cache.t2.micro"
    num_cache_nodes = 1
    parameter_group_name = "default.memcached1.5"
    port = 11211
    security_group_ids = [aws_security_group.vpro-backend-sg.id]
    subnet_group_name = aws_elasticache_subnet_group.vpro-elasticache-subnet-group.name
  
}

# AWS ActiveMQ(RabbitMQ) for queuing service
resource "aws_mq_broker" "vpro-rmq" {
    broker_name = "vpro-rabbitmq"
    engine_type = "ActiveMQ"
    engine_version = "5.15.0"
    host_instance_type = "mq.t2.micro"
    security_groups = [aws_security_group.vpro-backend-sg.id]
    subnet_ids = [module.vpc.private_subnets[0]]        # We are creatinig a sungle instance not a cluster so one subnet id is enough
    user {
      username = var.RMQ_USER
      password = var.RMQ_PASSWORD
    }

  
}