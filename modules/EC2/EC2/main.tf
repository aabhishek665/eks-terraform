data "aws_availability_zones" "azs" {}
resource "aws_instance" "instance" {
  count = var.create ? var.vm_count : 0

  ami                         = var.ami
  instance_type               = var.instance_type
  availability_zone           = data.aws_availability_zones.azs.names[count.index % length(data.aws_availability_zones.azs.names)]
  subnet_id                   = var.ec2_subnet_ids[count.index]
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses
  disable_api_termination     = var.disable_api_termination
  # cpu_core_count                       = var.cpu_core_count
  # cpu_threads_per_core                 = var.cpu_threads_per_core
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "enclave_options" {
    for_each = var.enclave_options
    content {
      enabled = var.enclave_options_enabled
    }
  }


  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      device_name           = lookup(ebs_block_device.value, "device_name", "")
      encrypted             = lookup(ebs_block_device.value, "encrypted", false)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      tags                  = lookup(ebs_block_device.value, "tags", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp2")
    }
  }
  ebs_optimized     = var.ebs_optimized
  get_password_data = var.get_password_data
  hibernation       = var.hibernation
  host_id           = var.host_id

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", open)
      dynamic "capacity_reservation_target" {
        for_each = var.capacity_reservation_target
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/../../../resources/${var.key_name}.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = var.inline-remote-exec
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = lookup(ephemeral_block_device.value, "device_name", null)
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", enabled)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", 1)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", optional)
    }
  }

  monitoring      = var.monitoring
  placement_group = var.placement_group

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(root_block_device.value, "encrypted", false)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      tags                  = lookup(root_block_device.value, "tags", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", gp2)
    }
  }
  source_dest_check = var.source_dest_check
  tenancy           = var.tenancy
  user_data_base64  = var.user_data_base64

  volume_tags = merge(
    var.volume_tags, {
      "Name" = var.name
    },
  )


  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }
  tags = merge(
    var.tags, {
      "Name" = var.name
    },
  )

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }
}