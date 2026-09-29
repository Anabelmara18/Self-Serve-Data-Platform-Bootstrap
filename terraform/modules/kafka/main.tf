resource "aws_key_pair" "kafka" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group_rule" "kafka_broker" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = var.private_sg_id
  description       = "Kafka broker traffic"
}

resource "aws_security_group_rule" "kafka_controller" {
  type              = "ingress"
  from_port         = 9093
  to_port           = 9093
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = var.private_sg_id
  description       = "Kafka KRaft controller traffic"
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = var.private_sg_id
  description       = "SSH from within VPC"
}

resource "aws_instance" "kafka" {
  ami                          = var.ami_id
  instance_type                = var.instance_type
  subnet_id                    = var.public_subnet_id
  associate_public_ip_address  = true
  vpc_security_group_ids       = [var.private_sg_id]
  key_name                     = aws_key_pair.kafka.key_name
  iam_instance_profile         = aws_iam_instance_profile.ssm.name

  user_data = file("${path.module}/install_kafka.sh")

  tags = {
    Name = "${var.project_name}-kafka-broker"
  }
}

resource "aws_iam_role" "ssm" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm.name
}

resource "aws_security_group_rule" "ssh_debug" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.private_sg_id
  description       = "TEMP - debug SSH access, remove after today"
}

resource "aws_security_group_rule" "kafka_debug" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.private_sg_id
  description       = "TEMP - debug producer access, remove after today"
}