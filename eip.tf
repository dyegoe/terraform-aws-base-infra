##### Create an Elastic IP #####
resource "aws_eip" "this" {
  for_each = var.instances
  vpc      = true
  tags     = { "Name" = "${var.resource_name_prefix}-${each.key}" }
}

##### Associate it to the instance #####
resource "aws_eip_association" "eip_assoc" {
  for_each      = var.instances
  instance_id   = aws_instance.this[each.key].id
  allocation_id = aws_eip.this[each.key].id
}
