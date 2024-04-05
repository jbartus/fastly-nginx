# fastly-nginx

## setup
- clone this repo and `cd` into the directory
- `terraform init`
- `cp terraform.tfvars.example terraform.tfvars`
- edit `terraform.tfvars` to populate your fastly api key and gcp project values
- `terraform apply`
- open the link in your browser


## logging
- uncomment line 23 - 35 and 52 - 55 in main.tf
- `terraform apply`
- ssh into the vm `ssh ubuntu@x.x.x.x`
```
sudo tee -a /etc/rsyslog.d/fastly.conf <<EOF > /dev/null
module(load="imtcp")
input(type="imtcp" port="514")
local0.info /var/log/fastly
EOF
sudo service rsyslog restart
sudo tail -f /var/log/fastly
```