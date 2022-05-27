##### Cloud init configuration template for ec2 instances #####
data "template_file" "ec2_instance" {
  template = <<EOF
#cloud-config
runcmd:
  - 'sed -i -E "s?^(#|)Port .*?Port ${var.ssh_port}?" /etc/ssh/sshd_config'
  - 'systemctl restart sshd'
  - 'ADD_USER=${var.cloud_init_user}'
  - 'useradd -m $ADD_USER -G wheel'
  - 'mkdir -p /home/$ADD_USER/.ssh'
  - 'echo "${var.cloud_init_public_key}" > /home/$ADD_USER/.ssh/authorized_keys'
  - 'echo "$ADD_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_ssh_users'
  - 'chown -R $ADD_USER:$ADD_USER /home/$ADD_USER/.ssh'
  - 'chmod 700 /home/$ADD_USER/.ssh'
  - 'chmod 600 /home/$ADD_USER/.ssh/authorized_keys'
EOF

}

##### Cloud init config for ec2 instances #####
data "template_cloudinit_config" "ec2_instance" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.ec2_instance.rendered
  }
}

##### Check for the newest AMI id to compare with the one provided to the module #####
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^amzn2-ami-kernel-5.10-hvm-2.0*"
}

##### Just get the current default tags ####
data "aws_default_tags" "current" {}

##### Locate the subnet to put the instance #####
data "aws_subnet" "this" {
  for_each          = var.instances
  vpc_id            = module.vpc.vpc_id
  availability_zone = each.value.availability_zone
  tags              = data.aws_default_tags.current.tags
  depends_on = [
    module.vpc
  ]
}

##### Get zone id using zone domain #####
data "aws_route53_zone" "this" {
  name         = var.zone_domain
  private_zone = false
}
