#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import db
from common.sqlmixins import SqlMixin
from datetime import datetime


class Environment(db.Model, SqlMixin):
    __tablename__ = 'environments'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(32), nullable=False, unique=True)
    desc = db.Column(db.String(255), default='')
    confs = db.relationship('Config', backref='env', lazy='dynamic')
    ctime = db.Column(db.DateTime, default=datetime.now)

    def __repr__(self):
        return '<Environment: {}>'.format(self.name)

    class Meta:
        ordering = ('-id',)


class Config(db.Model, SqlMixin):
    __tablename__ = 'configs'

    id = db.Column(db.Integer, primary_key=True)
    key = db.Column(db.String(32), nullable=False, unique=True)
    value = db.Column(db.Text, nullable=False)
    desc = db.Column(db.String(255), default='')
    ctime = db.Column(db.DateTime, default=datetime.now)
    environment = db.Column(db.Integer, db.ForeignKey('environments.id'))

    def __repr__(self):
        return '<Config: {}>'.format(self.key)

    class Meta:
        ordering = ('-id',)


class SystemConfig(db.Model, SqlMixin):
    key = db.Column(db.String(32), nullable=False, primary_key=True)
    value = db.Column(db.Text, nullable=False)
    desc = db.Column(db.String(255), default='')
    ctime = db.Column(db.DateTime, default=datetime.now)

    def __repr__(self):
        return '<SystemConfig: {}>'.format(self.key)

    class Meta:
        ordering = ('-key',)