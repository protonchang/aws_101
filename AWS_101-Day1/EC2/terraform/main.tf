# Paste this after the VPC settings


resource "aws_key_pair" "workshop-ssh-key" {
    key_name = "workshop-ssh-key"
    public_key = "REPLACE this with your own ssh key"
}
# Data source for Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Create Security Group
resource "aws_security_group" "ssh-external"{
    name = "Inbound-External-SSH"
    description = "Inbound SSH security Group"
    vpc_id = aws_vpc.workshop-vpc.id
    ingress {
        description = "Allow SSH Connection from Desginated Location"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["REPLACE WITH YOUR OWN IP CIDR"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "ssh-withinVPC" {
    name = "Inbound-Internal-SSH"
    description = "Allow VPC subnet SSH access"
    vpc_id = aws_vpc.workshop-vpc.id
    ingress {
        description = "Allow SSH connection within VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "allowHTTP" {
    name = "Inbound-HTTP"
    description = "Allow HTTP from Anywhere"
    vpc_id = aws_vpc.workshop-vpc.id
    ingress {
        description = "Allow HTTP from Anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

# Create the public EC2 instance
resource "aws_instance" "public" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "workshop-ssh-key"  # Replace with your key pair name

  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [
    aws_security_group.ssh-external.id,
    aws_security_group.ssh-withinVPC.id,
    aws_security_group.allowHTTP.id
    ]
  associate_public_ip_address = true
  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y unzip curl gnupg2 ca-certificates lsb-release ubuntu-keyring
                curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
                echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
                http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
                apt-get update
                apt-get install -y nginx
                cd /root
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                ./aws/install
                systemctl start nginx
                systemctl enable nginx
                EOF
  tags = {
    Name = "public-instance"
  }
}

# Create the private EC2 instance
resource "aws_instance" "private" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "workshop-ssh-key"  # Replace with your key pair name

  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.ssh-withinVPC.id]
  associate_public_ip_address = false

  tags = {
    Name = "private-instance"
  }
}


# Create an Elastic IP for the public instance
resource "aws_eip" "public" {
  instance = aws_instance.public.id
  domain   = "vpc"
}

# Output the public instance's Elastic IP
output "public_instance_eip" {
  value = aws_eip.public.public_ip
}

# Output the private instance's private IP
output "private_instance_ip" {
  value = aws_instance.private.private_ip
}