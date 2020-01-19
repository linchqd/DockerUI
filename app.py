#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import os
import logging
from flask import Flask
from flask_sockets import Sockets
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_restful import Api
import config
from logging.handlers import TimedRotatingFileHandler
from flask.logging import default_handler


# logging setting
log_dir = os.path.join(os.path.dirname(os.path.abspath(__name__)), 'logs/')
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(filename)s:%(module)s:%(funcName)s:%(lineno)d:%(message)s')
os.makedirs(log_dir, exist_ok=True)

info_handler = TimedRotatingFileHandler(
    filename='{}api.log'.format(log_dir), when='D', interval=1, backupCount=7, encoding='utf-8')
info_handler.setFormatter(formatter)
info_handler.setLevel(logging.DEBUG)

app = Flask(__name__)
app.logger.removeHandler(default_handler)
app.logger.addHandler(info_handler)

api = Api(app)
app.config.from_object(config)
db = SQLAlchemy(app)
ma = Marshmallow(app)
sockets = Sockets(app)