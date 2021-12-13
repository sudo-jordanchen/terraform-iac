provider "aws" {
  region = "ap-southeast-1"
  access_key = ""
  secret_key = ""
}

# Security group to only allow certain IPs from accessing the instance
resource "aws_security_group" "allow_rdp_1_ip" {
  name        = "allow_rdp_1_ip"
  description = "Allow 1 IP to access the RDP resource"

  ingress {
    description      = "Inbound RDP Traffic"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["116.15.134.127/32", "116.14.5.152/32"]
  }

  # Allow all outgoing connections to download files for installation
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_rdp"
  }
}

# Security group to only allow certain IPs from accessing the instance
resource "aws_security_group" "covenant_docker_sg" {
  name        = "covenant_docker_sg"
  description = "Allow IPs to access the Web resource"

  ingress {
    description      = "Inbound Covenant Traffic"
    from_port        = 7443
    to_port          = 7443
    protocol         = "tcp"
    cidr_blocks      = ["116.15.134.127/32", "116.14.5.152/32"]
  }

  # Allow all outgoing connections to download files for installation
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_covenant"
  }
}

# Linux Instance settings [ubuntu]
module "ec2_instance_linux" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "terraform-linux-instance"

  # ami-0fed77069cd5a6d6c [ubuntu AMI]
  ami                    = "ami-0fed77069cd5a6d6c"
  instance_type          = "t2.micro"
  key_name               = "Terraform-iac-2"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.covenant_docker_sg.id]

  # Shell script here
  user_data = <<-EOF
  #!/bin/bash
  curl https://raw.githubusercontent.com/sudo-jordanchen/terraform-iac/main/Linux_Userdata_Script.sh > userdata_script
  chmod 777 userdata_script
  ./userdata_script
                 EOF
}

# Windows Instance settings
module "ec2_instance_windows" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "terraform-windows-instance"

  ami                    = "ami-03cd0a8eda2957211"
  instance_type          = "t2.micro"
  key_name               = "Terraform-iac-2"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_rdp_1_ip.id]

  # Powershell script here
  user_data = <<-EOF
<powershell>
# Execution Policy Settings
Set-ExecutionPolicy Unrestricted -Force;

IEX (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/sudo-jordanchen/terraform-iac/main/Windows_Userdata_Script.ps1");
</powershell>
              EOF

  tags = {
    Terraform   = "true"
    Name = "terraform-windows-instance"
  }
}