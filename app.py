#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_restful import Api
from flask_socketio import SocketIO
import config


app = Flask(__name__)
api = Api(app)
app.config.from_object(config)
db = SQLAlchemy(app)
ma = Marshmallow(app)
socketio = SocketIO(app)
