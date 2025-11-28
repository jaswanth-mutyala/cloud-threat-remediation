# Get latest Linux Image
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "honeypot" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  
  # Attach the weak security group
  vpc_security_group_ids = [aws_security_group.honeypot_sg.id]

  tags = {
    Name = "Honeypot-Instance"
  }
}
