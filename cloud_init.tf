data "cloudinit_config" "instance" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "set-hostname.sh"
    content_type = "text/x-shellscript"

    content = file("${path.module}/templates/set-hostname.sh")
  }

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/templates/cloud-config.yaml",
      {
        ssh_port = var.ssh.port
      }
    )
  }
}
