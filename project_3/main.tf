resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ca-central-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "subnet1"
    }
}

resource "aws_subnet" "sub2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
    availability_zone = "ca-central-1b"
        map_public_ip_on_launch = true
        tags = {
        Name = "subnet2"
        }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gateway"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id   
    }
    tags = {
      Name = "main-route-table"
    }           
}

resource "aws_route_table_association" "sub1_association" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_route_table_association" "sub2_association" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}


resource "aws_security_group" "SG" {
  name        = "SG"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    } 
  ingress {
    from_port   = 22
    to_port     = 22
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
      Name = "main-security-group"
    }  
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-sudha2210-bucket-12345678"



  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}  
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_instance" "web" {
  ami              = "ami-0c0a551d0459e9d39"
  instance_type    = "t2.micro"
  subnet_id        = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.SG.id]  # Use vpc_security_group_ids instead of security_groups

  user_data_base64 = base64encode(file("userdata.sh"))

  tags = {
    Name = "WebServer"
  }
}

resource "aws_lb" "web_lb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.SG.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  enable_http2 = true

  tags = {
    Name = "web-alb"
  }
}


resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "WebTargetGroup"
  }
}
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web.id
  port             = 80

  depends_on = [aws_lb.web_lb]
}
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = {
    Name = "WebListener"
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.web_lb.dns_name    
  
}