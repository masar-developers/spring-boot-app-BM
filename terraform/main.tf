provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket =  "spring-app-terraform-backend-http"
    key    = "terraform/state"
    region = "us-east-1"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

#  First Application Subnet
resource "aws_subnet" "app_subnet_1" {
  vpc_id                   = aws_vpc.main.id
  cidr_block               = cidrsubnet(var.vpc_cidr, 8, 0) # first /24 subnet
  availability_zone        = element(data.aws_availability_zones.available.names, 0) # Get first AZ
  map_public_ip_on_launch  = true

  tags = {
    Name = "${var.app_subnet_name}-1"
  }
}

# Second Application Subnet
resource "aws_subnet" "app_subnet_2" {
    vpc_id                   = aws_vpc.main.id
    cidr_block               = cidrsubnet(var.vpc_cidr, 8, 1) # second /24 subnet
    availability_zone        = element(data.aws_availability_zones.available.names, 1) # Get second AZ
    map_public_ip_on_launch  = true
    tags = {
        Name = "${var.app_subnet_name}-2"
    }
}

# First DB Private Subnet
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2) # third /24 subnet
  availability_zone = element(data.aws_availability_zones.available.names, 0)


  tags = {
        Name = "${var.db_subnet_name}-1"
  }
}
# Second DB Private Subnet
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3) # forth /24 subnet
  availability_zone = element(data.aws_availability_zones.available.names, 1)


  tags = {
        Name = "${var.db_subnet_name}-2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}


resource "aws_route_table_association" "app_subnet_assoc_1" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "app_subnet_assoc_2" {
  subnet_id      = aws_subnet.app_subnet_2.id
  route_table_id = aws_route_table.main.id
}



resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "spring-app-security-group"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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


resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "spring-app-launch-templates"
  image_id      = "ami-0bb84b8ffd87024d8"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.main.key_name
  
  vpc_security_group_ids = [aws_security_group.main.id]
  
  user_data = base64encode(file("user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Docker-EC2"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                  = "spring-app-autoscaling-group"
  launch_template {
    id = aws_launch_template.main.id
  }
  vpc_zone_identifier   = [aws_subnet.app_subnet_1.id, aws_subnet.app_subnet_2.id] # Use both subnets for ASG
  min_size              = 1
  max_size              = 3
  desired_capacity      = 1

  health_check_type = "ELB"  
  
  lifecycle {
    create_before_destroy = true
  }
}


# Application Load Balancer
resource "aws_lb" "main" {
  name               = "spring-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [aws_subnet.app_subnet_1.id, aws_subnet.app_subnet_2.id] # Use both subnets for ALB
}

# Target Group
resource "aws_lb_target_group" "main" {
  name       = "spring-app-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  target_type = "instance"
    health_check {
    path = "/"  
    protocol = "HTTP"
  }
}


# Listener for the load balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Attach Auto Scaling Group to Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}


# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "spring-app-rds-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id] # Use both db subnets
}

# RDS Security Group
resource "aws_security_group" "rds" {
    vpc_id = aws_vpc.main.id
    name = "spring-app-rds-security-group"
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.main.id] # allow only instances from main sec group
    }
    egress {
       from_port = 0
       to_port = 0
       protocol = "-1"
       cidr_blocks = ["0.0.0.0/0"]
    }
}


# RDS Instance
resource "aws_db_instance" "main" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0" #change as needed
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot  = true
  publicly_accessible = false # set to false in production

}

output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}