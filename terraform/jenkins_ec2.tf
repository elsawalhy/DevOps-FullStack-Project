
# <<==>> Create sercurity group <<==>>

resource "aws_security_group" "serverSG" {
  
  name   = "Myapp-SG"
  vpc_id = aws_vpc.jenkins-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# <<==>> Create ami for Ec2 <<==>>

data "aws_ami" "ubuntu-ami" {
  most_recent = true
  owners = ["099720109477"] 
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# <<==>> Create key-pair for server <<==>>

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = var.public_key
}


# <<==>> Create Ec2  <<==>>

resource "aws_instance" "jenkins-server" {
  ami             = data.aws_ami.ubuntu-ami.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.subnet_1.id
  vpc_security_group_ids = [aws_security_group.serverSG.id]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name


  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    encrypted   = false
  }

  tags = {
    Name = "jenkins-server"
  }
}
