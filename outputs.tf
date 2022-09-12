output "instances" {
  description = "It returns an object of all instances created by the module."
  value = {
    for instance, _ in var.instances : instance => {
      ami                 = data.aws_ami.amazon_linux_2.id != aws_instance.this[instance].ami ? "New AMI: ${data.aws_ami.amazon_linux_2.id}" : "AMI is up-to-date"
      availability_zone   = var.instances[instance].availability_zone
      id                  = aws_instance.this[instance].id
      private_ip          = aws_instance.this[instance].private_ip
      public_ip           = aws_eip.this[instance].public_ip
      route53             = aws_route53_record.this[instance].name
      security_group_id   = module.security_group[instance].security_group_id
      security_group_name = module.security_group[instance].security_group_name
      ssh_port            = var.ssh_port
      subnet_id           = data.aws_subnet.this[instance].id
    }
  }
}
