resource "aws_instance" "vpro-bastion" {

  ami = lookup(var.AMIs, var.AWS_REGION) # this lookup function will look for the map variable "AMI" and in that it will look for a key region name
  # var.aws_REGION will return the region name and accrodingly it will search for the AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.Vprofile-key.key_name

  subnet_id              = module.vpc.public_subnets[0] # Bastion host will be created in the "first public subnet of VPC"
  count                  = var.INSTANCE_COUNT
  vpc_security_group_ids = [aws_security_group.vpro-bastionHost-sg.id]
  tags = {
    name = "vpro-bastion host"
  }

  # file provisioned is used to send the template file or any othe type of file to the server(Here bastion host)

  provisioner "file" {
    content = templatefile("db-deploy.tmpl", { rds-endpoint = aws_db_instance.vpro-rds.address, dbuser = var.DB_USER, dbpass = var.DB_PASSWORD })
    # we have already created the db-deploy.tmpl which contains the shell script. Now using file provsioned and templatefile() function we are sending the file to bastion host
    # Here templatefile is used because the file that we are sending is not a normal text file, its a template file abd it also requires some environment variable to be passed at the run time


    destination = "/tmp/vprofile-dbdeploy.sh" # we are renaming the db-deoliy file as vprofile-dbdeoloy and placing it in the tmp directory

  }

  # remote-exec is used to execute an executable file remotely in the server(Here bastion host)

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vprofile-dbdeploy.sh", # Giving the executable permission
      "sudo /tmp/vprofile-dbdeploy.sh"      # this will execute the db-deploy template
    ]

  }

  # Letting terraform know about on which server it has to perform the above actions

  connection {
    user        = var.USERNAME
    private_key = file(var.PRIVATE_KEY_PATH)
    host        = self.public_ip # Here self means the server that is launched itself( here Bastion Host )
  }

  # RDS instance has to be ready before the SQL schema is run. Hence we are using depends_on to create a dependancy on the aws_db_instance.vpro-rds where the SQL schema will run

  depends_on = [aws_db_instance.vpro-rds]

}