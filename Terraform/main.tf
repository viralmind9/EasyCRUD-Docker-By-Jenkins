provider "aws" {
    region = var.region
}

resource "aws_instance" "EC2"{
    ami = var.ami
    instance_type = var.instance_type
    tags = {
      Name = var.instance_type
    }
}
