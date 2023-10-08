variable "AWS_REGION" {
    default = "us-east-1"
  
}

variable "AMIs" {
    type = map
    default = {
        us-east-1 = "ami-053b0d53c279acc90"
        us-east-2 = "ami-024e6efaf93d85776"
    }
  
}

variable "PRIVATE_KEY_PATH" {
    default = "vprofile-key"
  
}
variable "PUBLIC_KEY_PATH" {
  default = "vprofile-key.pub"
}
variable "USERNAME" {
    default = "ubuntu"
  
}

variable "MY_IP" {
    default = "106.221.149.15/32"
  
}

variable "RMQ_USER" {
    default = "rabbit"
  
}

variable "RMQ_PASSWORD" {
    default = "Pass@780956283"
  
}

variable "DB_USER" {
  default = "admin"
}

variable "DB_PASSWORD" {
    default = "admin123"
  
}

variable "DB_NAME" {
  default = "accounts"
}

variable "INSTANCE_COUNT" {
    default = "1"
  
}

variable "VPC_NAME" {
    default = "Vprofile-VPC"
  
}

variable "ZONE-1" {
  default = "us-east-1a"
}
variable "ZONE-2" {
  default = "us-east-1b"
}
variable "ZONE-3" {
  default = "us-east-1c"
}

variable "VPC_CIDER" {
  default = "172.21.0.0/16"


}

variable "PubSub1_CIDER" {
    default = "172.21.1.0/24"
  
}

variable "PubSub2_CIDER" {
  default = "172.21.2.0/24"

}

variable "PubSub3_CIDER" {
  default = "172.21.3.0/24"

}

variable "PrivSub1_CIDER" {
    default = "172.21.4.0/24"
  
}

variable "PrivSub2_CIDER" {
  default = "172.21.5.0/24"
}

variable "PrivSub3_CIDER" {
    default = "172.21.6.0/24"
  
}