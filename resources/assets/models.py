#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import db
from common.sqlmixins import SqlMixin
from datetime import datetime


class Pkey(db.Model, SqlMixin):
    __tablename__ = 'pkeys'
    id = db.Column(db.Integer, primary_key=True, nullable=False)
    name = db.Column(db.String(32), nullable=False, unique=True)
    desc = db.Column(db.String(255))
    private_key = db.Column(db.String, nullable=False)
    publice_key = db.Column(db.String, nullable=False)
    ctime = db.Column(db.DateTime, default=datetime.now)

    def __repr__(self):
        return '<Pkey {}: {}>'.format(self.id, self.name)

    class Meta:
        ordering = ('-id',)
