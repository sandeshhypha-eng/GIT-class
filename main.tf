/**
/** 
******************************VPC for practice******************************
**/
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs

resource "aws_vpc" "hypha-vpc-1" {
  cidr_block = "172.16.0.0/22"

  tags = {
    Name = "practice"
  }
}

/** 
******************************subnets for practice******************************
**/
#tfsec:ignore:aws-ec2-no-public-ip-subnet
#tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "hypha-subnet-public-1" {
  vpc_id            = aws_vpc.hypha-vpc-1.id
  cidr_block        = "172.16.0.0/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "practice-public-1"
}
}


resource "aws_subnet" "hypha-subnet-private-1" {
  vpc_id            = aws_vpc.hypha-vpc-1.id
  cidr_block        = "172.16.0.128/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "practice-private-1"
  }
}

/** 
****************************** EC2 ******************************
**/
#tfsec:ignore:aws-ec2-enable-at-rest-encryption
#tfsec:ignore:aws-ec2-enforce-http-token-imds
resource "aws_instance" "hypha-ec2-1" {
  ami           = "ami-0157af9aea2eef346" # Amazon Linux 2 AMI (HVM)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.hypha-subnet-public-1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.hypha-ssh.id]
  tags = {
    Name = "practice-ec2-1"
  }
}

 
/**
****************************** Internet Gateway and Route Table ******************************
**/
#tfsec:ignore:
resource "aws_internet_gateway" "hypha-igw" {
  vpc_id = aws_vpc.hypha-vpc-1.id
  tags = { Name = "practice-igw" }
}

resource "aws_route_table" "hypha-public-rt" {
  vpc_id = aws_vpc.hypha-vpc-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hypha-igw.id
  }
  tags = { Name = "practice-public-rt" }
}

resource "aws_route_table_association" "hypha-public-rt-assoc" {
  subnet_id      = aws_subnet.hypha-subnet-public-1.id
  route_table_id = aws_route_table.hypha-public-rt.id
}

/** 
****************************** Security Group ******************************
**/
#tfsec:ignore:aws-ec2-add-description-to-security-group
#tfsec:ignore:aws-ec2-add-description-to-security-group-rule
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
#tfsec:ignore:aws-ec2-no-public-egress-sgr

resource "aws_security_group" "hypha-ssh" {
  name   = "hypha-ssh"
  vpc_id = aws_vpc.hypha-vpc-1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "Security group for SSH access"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "practice-ssh-sg" }
}