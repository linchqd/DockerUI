#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import os
import logging
from logging.config import dictConfig
from flask import Flask
from flask_sockets import Sockets
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_restful import Api
import config


# logging setting
log_dir = os.path.join(os.path.dirname(os.path.abspath(__name__)), 'logs/')
os.makedirs(log_dir, exist_ok=True)
dictConfig({
    'version': 1,
    'formatters': {'default': {
        'format': '%(asctime)s %(levelname)s: %(filename)s:%(module)s:%(funcName)s:%(lineno)d:%(message)s',
    }},
    'handlers': {'file': {
        'class': 'logging.handlers.TimedRotatingFileHandler',
        'filename': '{}api.log'.format(log_dir),
        'when': 'D',
        'interval': 1,
        'backupCount': 7,
        'encoding': 'utf-8',
        'formatter': 'default'
    }},
    'root': {
        'level': 'INFO',
        'handlers': ['file']
    }
})

app = Flask(__name__)
api = Api(app)
app.config.from_object(config)
db = SQLAlchemy(app)
ma = Marshmallow(app)
sockets = Sockets(app)