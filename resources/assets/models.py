#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import db
from common.sqlmixins import SqlMixin
from datetime import datetime


class ServerModel(db.Model, SqlMixin):
    __tablename__ = 'servers'

    id = db.Column(db.Integer, primary_key=True)
    ip = db.Column(db.String(32), nullable=False, unique=True)
    port = db.Column(db.Integer)
    username = db.Column(db.String(16), nullable=False)
    password = db.Column(db.String(1024), nullable=False)
    desc = db.Column(db.String(255), default='')
    type = db.Column(db.Integer, default=1)
    zone = db.Column(db.String(50), default='local', nullable=False)
    ctime = db.Column(db.DateTime, default=datetime.now)

    def __repr__(self):
        return '<Server: {}>'.format(self.ip)

    class Meta:
        ordering = ('-id',)
