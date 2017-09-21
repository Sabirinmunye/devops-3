provider "aws" {
  region = "eu-west-2"
} 

#Create VPC
resource "aws_vpc" "sabirin" {
  tags {
    Name = "sabirin - VPC"
  }
  cidr_block = "11.5.0.0/16"
}

resource "aws_subnet" "web" {
  vpc_id     = "${aws_vpc.sabirin.id}"
  cidr_block = "11.5.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "Web - Private"
  }
}

resource "aws_subnet" "sab-db" {
  cidr_block = "11.5.2.0/24"
  vpc_id ="${aws_vpc.sabirin.id}"
  map_public_ip_on_launch = false
  tags {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "web-sab"  {
  name ="web-sab"
  description = "Allow all inbound traffic through port 80 only"
  vpc_id ="${aws_vpc.sabirin.id}"

  ingress{
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress{
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "web-sab"
  }
}

resource "aws_security_group" "db_security" {
  vpc_id ="${aws_vpc.sabirin.id}"
  name = "db_security"
  

  ingress{
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups =["${aws_security_group.web-sab.id}"]
  }
  
  egress{
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
data "aws_ami" "web" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["sab-web-prod*"]
  }

  most_recent = true
}

data "template_file" "init_script" {
  template = "${file("${path.module}/init.sh")}"
} 


resource "aws_instance" "web" {
  ami           = "${data.aws_ami.web.id}"
  instance_type = "t2.micro"
  vpc_security_group_ids =["${aws_security_group.web-sab.id}"]
  subnet_id ="${aws_subnet.web.id}"
  user_data = "${data.template_file.init_script.rendered}"
  depends_on = ["aws_instance.database"]

  tags {
    Name = "web-sab"
  }
}

resource "aws_instance" "database" {

  ami           = "ami-6edccf0a"
  instance_type = "t2.micro"
  vpc_security_group_ids =["${aws_security_group.db_security.id}"] 
  subnet_id ="${aws_subnet.sab-db.id}"
  private_ip = "11.5.2.6"
  tags {
    Name = "DB-sab"
  }
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Create internet gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.sabirin.id}"
}

# Add route to internet gateway in route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.sabirin.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table" "database" {
    vpc_id = "${aws_vpc.sabirin.id}"

    tags {
        Name = "Sabnet route table"
    }
}

resource "aws_route_table_association" "database" {
  subnet_id      = "${aws_subnet.sab-db.id}"
  route_table_id = "${aws_route_table.database.id}"
}

