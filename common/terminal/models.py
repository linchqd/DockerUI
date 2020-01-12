#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import db
from common.sqlmixins import SqlMixin
from datetime import datetime


class SshKeyModel(db.Model, SqlMixin):
    __tablename__ = 'ssh_keys'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(16), nullable=False, unique=True)
    pub_key = db.Column(db.String(1024), nullable=False)
    pkey = db.Column(db.String(2048), nullable=False)
    ctime = db.Column(db.DateTime, default=datetime.now)

    def __repr__(self):
        return '<pkey: {}>'.format(self.name)

    class Meta:
        ordering = ('-id',)
