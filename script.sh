#! /bin/bash
sudo apt update && apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo echo "<html><head><style>body{background-color:black;color:lightblue;}</style></head><body><h1>Apache has been successfully installed</h1> </body></html>" > /var/www/html/index.html
