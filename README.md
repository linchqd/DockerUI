# DockerUI

## Deploy
```
git clone https://github.com/linchqd/DockerUI.git
cd DockerUI
docker build --rm -t dockerui:v1 .
docker run --name dockerui -p 80:80 -e MYSQL_SETTING='user:password@host:port/dbname' -e API_SERVER='host:port' -d dockerui:v
```
## Init db
```
docker run --name mariadb -v /data/mysql-data:/var/lib/mysql -p 3306:3306 -d mariadb:latest
docker exec -it dockerui python3 /dockerui/api/manage.py init_db
```
