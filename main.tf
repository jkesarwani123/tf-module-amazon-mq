# Create Security Group
resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "RABBITMQ"
    from_port        = var.port_no
    to_port          = var.port_no
    protocol         = "tcp"
    cidr_blocks      = var.allow_db_cidr
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_cidr
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sg" })
}
# Create a simple instance for RabbitMQ
resource "aws_instance" "rabbitmq" {
  ami           = data.aws_ami.centos.id
  instance_type = var.instance_type
  subnet_id     = var.subnets[0]
  vpc_security_group_ids = [aws_security_group.main.id]
  tags          = merge(var.tags, { Name = "${var.name}-${var.env}" })

  root_block_device {
    encrypted = true
    kms_key_id = var.kms_arn
  }
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    rabbitmq_appuser_password = data.aws_ssm_parameter.rabbitmq_appuser_password.value
  }))

}

# Create DNS record
resource "aws_route53_record" "main" {
  zone_id = var.domain_id
  name    = "rabbitmq-${var.env}"
  type    = "A"
  ttl     = 30
  records = [aws_instance.rabbitmq.private_ip]
}

#resource "aws_instance" "instance" {
#  ami           = data.aws_ami.centos.image_id
#  instance_type = var.instance_type
#  vpc_security_group_ids = [ data.aws_security_group.selected.id ]
#  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
#  tags = var.app_type == "app" ? local.app_tags : local.db_tags
#}