provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_instance" "paasta" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  user_data              = file("initial_deploy.sh")

  tags = {
    Name = var.instance_name
  }
}
resource "null_resource" "copyjob" {

  connection {
    type        = "ssh"
    host        = aws_instance.paasta.public_ip
    user        = "ubuntu"
    private_key = file("/home/burhanuddin/Dev/devops/paasta/buildserver/terraform/awscred.pem")
  }

  provisioner "file" {
    source      = "/home/burhanuddin/Dev/devops/paasta/buildserver/job.tar"
    destination = "/home/ubuntu/job.tar"
  }


  depends_on = [aws_instance.paasta]

}
resource "null_resource" "runjob" {

  connection {
    type        = "ssh"
    host        = aws_instance.paasta.public_ip
    user        = "ubuntu"
    private_key = file("/home/burhanuddin/Dev/devops/paasta/buildserver/terraform/awscred.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "docker load -i job.tar",
      "docker run --name job -d -p 80:5000 job"
    ]
  }


  depends_on = [null_resource.copyjob]

}
resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

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
  # ingress {
  #   from_port   = 5000
  #   to_port     = 5000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
