resource "aws_launch_template" "launch_template" {
  name                   = var.name
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  description            = var.description
  vpc_security_group_ids = var.vpc_security_group_ids

  dynamic "block_device_mappings" {
    for_each = length(var.block_device_mappings) > 0 ? var.block_device_mappings : []

    content {
      device_name = block_device_mappings.value.device_name != "" ? block_device_mappings.value.device_name : null
      no_device   = block_device_mappings.value.no_device != "" ? block_device_mappings.value.no_device : null
      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
        iops                  = block_device_mappings.value.iops
        kms_key_id            = block_device_mappings.value.kms_key_id
        snapshot_id           = block_device_mappings.value.snapshot_id
        throughput            = block_device_mappings.value.throughput
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = length(var.network_interfaces) > 0 ? [var.network_interfaces] : []
    content {
      associate_carrier_ip_address = network_interfaces.value.associate_carrier_ip_address
      associate_public_ip_address  = network_interfaces.value.associate_public_ip_address
      delete_on_termination        = network_interfaces.value.delete_on_termination
      description                  = network_interfaces.value.description
      device_index                 = network_interfaces.value.device_index
      interface_type               = network_interfaces.value.interface_type
      ipv6_addresses               = network_interfaces.value.ipv6_addresses
      network_interface_id         = network_interfaces.value.network_interface_id
      private_ip_address           = network_interfaces.value.private_ip_address
      ipv4_addresses               = network_interfaces.value.ipv4_addresses
      security_groups              = network_interfaces.value.security_groups
      subnet_id                    = network_interfaces.value.subnet_id
    }
  }
  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [var.iam_instance_profile] : []
    content {
      arn = iam_instance_profile.value.arn
    }
  }
  #instance_initiated_shutdown_behavior = var.shutdown_behavior
  dynamic "hibernation_options" {
    for_each = var.hibernation_options != null ? [var.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }
  disable_api_termination = var.disable_api_termination
  dynamic "monitoring" {
    for_each = var.monitoring != null ? [var.monitoring] : []
    content {
      enabled = monitoring.value.enabled
    }
  }
  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }
  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }
  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      affinity                = placement.value.affinity
      availability_zone       = placement.value.availability_zone
      group_name              = placement.value.group_name
      host_id                 = placement.value.host_id
      host_resource_group_arn = placement.value.host_resource_group_arn
      spread_domain           = placement.value.spread_domain
      tenancy                 = placement.value.tenancy
      partition_number        = placement.value.partition_number
    }
  }
  ebs_optimized = var.ebs_optimized

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
      capacity_reservation_target {
        capacity_reservation_id = capacity_reservation_specification.value.capacity_reservation_id
      }
    }
  }
  ram_disk_id = var.ram_disk_id
  dynamic "enclave_options" {
    for_each = var.enclave_options != null ? [var.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }
  dynamic "license_specification" {
    for_each = var.license_specification != null ? [var.license_specification] : []
    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [var.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }


  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
    }
  }
  user_data = var.user_data != null ? base64encode(var.user_data) : null
  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
  lifecycle {
    create_before_destroy = true
  }
}
