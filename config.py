#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import pymysql


SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:root@mysql:3306/dockerui'
SQLALCHEMY_TRACK_MODIFICATIONS = False
SECRET_KEY = '\xf4sC0\x95\xc6\xb5\xa1\xd2\xbe-OL@\xefn\xa8 \x13\x1e\x0b\xc8\x89\xf0'
JSON_AS_ASCII = False
RESTFUL_JSON = dict(ensure_ascii=False)
CELERY_BROKER_URL = 'redis://redis:6379'
CELERY_RESULT_BACKEND = 'redis://redis:6379'
