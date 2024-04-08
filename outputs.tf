output "curl_command" {
  value = "curl -svo /dev/null http://${google_compute_instance.nginx-vm.network_interface.0.access_config.0.nat_ip}"
}

output "ssh_command" {
  description = "command to ssh into ubuntu vm running nginx"
  value       = "ssh ubuntu@${google_compute_instance.nginx-vm.network_interface.0.access_config.0.nat_ip}"
}

output "browser_url" {
  description = "url to curl or load in browser"
  value       = "https://front-nginx-${local.rid}.global.ssl.fastly.net/"
}