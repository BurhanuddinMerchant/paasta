provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_instance" "paasta" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
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
    private_key = file("/home/burhanuddin/Dev/devops/paasta/terraform/awscred.pem")
  }

  provisioner "file" {
    source      = "/home/burhanuddin/Dev/devops/paasta/buildserver"
    destination = "/home/ubuntu/"
  }


  depends_on = [aws_instance.paasta]

}
