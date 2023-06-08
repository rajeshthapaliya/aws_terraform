#!/bin/bash
# Use this for your user data (script from top to bottom)
# Install Apache HTTP Server
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
