#!/bin/bash

set -e

usage() {
	echo "usage: docker run -e MYSQL_SETTING='username:password@host:port/database_name' -e API_SERVER='ip:port' ..."
}

if [ -z "$MYSQL_SETTING" ]; then
	echo "ERROR! Please configure database connection information"
	usage
	exit 1
fi

cat > /dockerui/api/config.py <<EOF
#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import pymysql


SECRET_KEY = '\xf4sC0\x95\xc6\xb5\xa1\xd2\xbe-OL@\xefn\xa8 \x13\x1e\x0b\xc8\x89\xf0'
JSON_AS_ASCII = False
RESTFUL_JSON = dict(ensure_ascii=False)
SQLALCHEMY_DATABASE_URI = "mysql+pymysql://$MYSQL_SETTING"
SQLALCHEMY_TRACK_MODIFICATIONS = False
EOF

if [ -z $API_SERVER ];then
	API_SERVER='127.0.0.1:8000'
fi

sed -i "s/API_SERVER/$API_SERVER/" /dockerui/gunicorn.py
sed -i "s/API_SERVER/$API_SERVER/" /etc/nginx/nginx.conf

/usr/bin/supervisord -c /etc/supervisord.conf
