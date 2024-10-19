data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "gitops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "gitops-vpc"
  }
}

resource "aws_internet_gateway" "gitops_igw" {
  vpc_id = aws_vpc.gitops_vpc.id

  tags = {
    Name = "gitops-igw"
  }
}

resource "aws_route_table" "gitops_rt" {
  vpc_id = aws_vpc.gitops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gitops_igw.id
  }

  tags = {
    Name = "gitops-rt"
  }
}

resource "aws_subnet" "gitops_subnet" {
  vpc_id                  = aws_vpc.gitops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "gitops-subnet"
  }
}

resource "aws_route_table_association" "gitops_rta" {
  subnet_id      = aws_subnet.gitops_subnet.id
  route_table_id = aws_route_table.gitops_rt.id
}

resource "aws_security_group" "gitops_sg" {
  name        = "gitops_sg"
  description = "Allow port 3000"
  vpc_id      = aws_vpc.gitops_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gitops-sg"
  }
}

resource "aws_instance" "grafana_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.gitops_subnet.id
  vpc_security_group_ids = [aws_security_group.gitops_sg.id]
  user_data              = file("userdata.tftpl")

  root_block_device {
    volume_type = "gp3"
    iops        = 3000 # Optional: Specify IOPS if needed
    throughput  = 125  # Optional: Specify throughput in MB/s if needed
    tags = {
      Service     = var.service_name
      Environment = var.environment
    }
  }

  tags = {
    Name = "grafana-server"
  }
}

# Terraform checks
# https://developer.hashicorp.com/terraform/language/checks
check "grafana_health_check" {
  data "http" "test_grafana" {
    url = "http://${aws_instance.grafana_server.public_ip}:3000"
    retry {
      attempts = 5
    }
  }
  assert {
    condition     = data.http.test_grafana.status_code == 200
    error_message = "Grafana is inaccessible on port 3000."
  }
}
