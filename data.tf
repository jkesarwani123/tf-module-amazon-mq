data "aws_ami" "centos" {
  owners           = ["973714476881"]
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
}

data "aws_ssm_parameter" "rabbitmq_appuser_password" {
  name = "${var.env}.${var.name}.rabbitmq_appuser_password"
}
