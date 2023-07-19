resource "null_resource" "alb_ingress_controller" {
  depends_on = [
    module.bastion_server,
    resource.null_resource.script_file
  ]
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/alb-ingress-controller-setup.sh",
      "sh /tmp/alb-ingress-controller-setup.sh ${var.AccountId} ${var.cluster_name} ${var.region} ${var.alb_ingress_role_name}"
    ]
    connection {
      type        = "ssh"
      host        = module.bastion_server.public_ip
      user        = "ec2-user"
      private_key = file("./${var.bastion_key_pair}.pem")
    }
  }
}
resource "null_resource" "script_file" {
  depends_on = [
    module.bastion_server
  ]
  provisioner "file" {
    source      = "./alb-ingress-controller-setup.sh"
    destination = "/tmp/alb-ingress-controller-setup.sh"

    connection {
      type        = "ssh"
      host        = module.bastion_server.public_ip
      user        = "ec2-user"
      private_key = file("./${var.bastion_key_pair}.pem")
    }
  }
}