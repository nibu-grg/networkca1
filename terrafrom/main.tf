# Provider Configuration
provider "aws" {
  region = "eu-west-1"  
}

# Define the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "AutoNetworkCA1"
  }
}

# Define a public subnet
resource "aws_subnet" "ca1_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1c"     # Set your preferred availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "AutoNetworkSubnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "ca1_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "AutoNetworkInternetGateway"
  }
}

# Create a Route Table and associate with the subnet
resource "aws_route_table" "ca1_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ca1_igw.id
  }

  tags = {
    Name = "AutoNetworkRouteTable"
  }
}

resource "aws_route_table_association" "ca1_route_table_association" {
  subnet_id      = aws_subnet.ca1_subnet.id
  route_table_id = aws_route_table.ca1_route_table.id
}

# Define a Security Group for SSH and HTTP
resource "aws_security_group" "ca1_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Ingress rule for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AutoNetworkSecurityGroup"
  }
}

# Define the EC2 Instance
resource "aws_instance" "ca1_instance" {
  ami           = "ami-0d64bb532e0502c46"   # Amazon Linux 2 AMI in eu-west-1
  instance_type = "t2.micro"                # Free-tier eligible instance type
  subnet_id     = aws_subnet.ca1_subnet.id
  vpc_security_group_ids = [aws_security_group.ca1_sg.id]  # Use the security group ID instead of name
  key_name      = "key_value"               # Replace with your actual key pair name

  tags = {
    Name = "AutoNetworkEC2Instance"
  }
}

# Output the instance's public IP
output "instance_ip" {
  value = aws_instance.ca1_instance.public_ip
}
