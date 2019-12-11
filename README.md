# DockerUI

## Deploy
```
git clone https://github.com/linchqd/DockerUI.git
cd DockerUI
docker build --rm -t dockerui:v1 .
docker run --name dockerui -p 80:80 -e MYSQL_SETTING='root:root@10.0.2.15:3306/dockerui' -e API_SERVER='127.0.0.1:8000' -d dockerui:v
```
## Init db
```
docker run --name mariadb -v /data/mysql-data:/var/lib/mysql -p 3306:3306 -d mariadb:latest
docker exec -it dockerui python3 /dockerui/api/manage.py init_db
```
