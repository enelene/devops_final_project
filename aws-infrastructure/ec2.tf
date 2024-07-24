# Create Bastion Host in public subnet
resource "aws_instance" "bastion" {
  ami             = "ami-071878317c449ae48"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.ec2_sg.id]
  key_name        = aws_key_pair.final_project_key.key_name

  tags = {
    Name = "bastion-host"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.final_project_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "inventory.ini"
    destination = "/home/ec2-user/inventory.ini"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.final_project_key.private_key_pem
      host        = self.public_ip
    }
  }


  provisioner "file" {
    source      = "playbook.yml"
    destination = "/home/ec2-user/playbook.yml"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.final_project_key.private_key_pem
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.final_project_key.private_key_pem
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "final_project_key.pem"
    destination = "/home/ec2-user/final_project_key.pem"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.final_project_key.private_key_pem
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y ansible",
      "sudo yum install -y git",
      "sudo amazon-linux-extras install docker -y",
      "sudo amazon-linux-extras install ansible2 -y",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
      "sudo yum install -y nginx",
      "sudo systemctl stop nginx",
      "chmod 400 /home/ec2-user/final_project_key.pem",
      # "ansible-playbook -i inventory.ini, --connection local /home/ec2-user/playbook.yml"
    ]
  }
}

# Create EC2 Instances in private subnets
resource "aws_instance" "final_web" {
  count           = 2
  ami             = "ami-071878317c449ae48"
  instance_type   = "t2.micro"
  subnet_id       = element([aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id], count.index)
  security_groups = [aws_security_group.ec2_sg.id]
  key_name        = aws_key_pair.final_project_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "Hello from $(hostname)" | sudo tee /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "final-web-instance-${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = true
  }

  connection {
    type         = "ssh"
    user         = "ec2-user"
    private_key  = tls_private_key.final_project_key.private_key_pem
    host         = self.private_ip
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
  }

  provisioner "remote-exec" {
    inline = [
      "if ! command -v nginx &> /dev/null; then sudo yum install -y nginx; fi",
      "sudo systemctl start nginx || sudo systemctl restart nginx"
    ]
  }

  depends_on = [aws_nat_gateway.final_project_nat, aws_lb.final_project_alb]
}
