resource "aws_security_group_rule" "airflow_webserver" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = var.private_sg_id
  description       = "Airflow webserver UI"
}

resource "aws_instance" "airflow" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.private_sg_id]
  key_name                    = "${var.project_name}-key"

  user_data = file("${path.module}/install_airflow.sh")

  tags = {
    Name = "${var.project_name}-airflow"
  }
}

resource "aws_security_group_rule" "airflow_webserver_debug" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # verify this is still your current IP
  security_group_id = var.private_sg_id
  description       = "TEMP - debug Airflow UI access, remove after"
}