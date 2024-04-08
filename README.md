# fastly-nginx

## setup
- clone this repo and `cd` into the directory
- `terraform init`
- `cp terraform.tfvars.example terraform.tfvars`
- edit `terraform.tfvars` to populate your fastly api key and gcp project values
- `terraform apply`

## caching
- curl the vm ip, notice the lack of a cache-control header
- ssh into the vm
- `sudo tail -f /var/log/nginx/access.log`, notice your curl request is already there
- load the url from the terraform output in a browser tab, back in the terminal notice the request came from a new (fastly) ip
- refresh a few times, notice the requests don't hit nginx
- inspect a request in chrome, notice the HITs and age header climbing up

## headers
- ^C the log tail
- `sudo vi /etc/nginx/sites-available/default`
- look for the `location` section already in there and copy/paste the below snippet after it
```
        location ~ \.html$ {
                add_header Cache-Control "max-age=10";
        }
```
- restart nginx with `service nginx restart`
- `exit` the vm
- re-run your curl of the direct ip, notice there is now a `cache-control` header with a value of `max-age=10`
- refresh your browser tab, notice its still a HIT with an Age well over 10 seconds
- purge the url like so:
```
curl -X PURGE http://x.x.x.x
```
- refresh in your browser again, notice its a MISS and has the `cache-control` header
- refresh again, notice it becomes HITS and the `age` increases
- wait 10 seconds
- refresh again, notice it was a MISS again
- refresh a bunch more, notice that its mostly HITs, and that age climbs up, but doesn't go over 10

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

## shielding
- uncommment line 49 in main.tf
- `terraform apply`