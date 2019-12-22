#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import db
from common.sqlmixins import SqlMixin
from datetime import datetime


class DocsKind(db.Model, SqlMixin):
    __tablename__ = 'document_kinds'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(16), nullable=False, unique=True)
    ctime = db.Column(db.DateTime, default=datetime.now)
    docs = db.relationship('Doc', backref='kind', lazy='dynamic')

    def __repr__(self):
        return '<wikiKind: {}>'.format(self.name)

    class Meta:
        ordering = ('-id',)


class Doc(db.Model, SqlMixin):
    __tablename__ = 'documents'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(64), nullable=False)
    context = db.Column(db.Text, nullable=False)
    tag = db.Column(db.String(32), nullable=False)
    author = db.Column(db.String(16), nullable=False)
    ctime = db.Column(db.DateTime, default=datetime.now)
    kind_id = db.Column(db.Integer, db.ForeignKey('document_kinds.id'))

    def __repr__(self):
        return '<Doc id: {}>'.format(self.id)

    class Meta:
        ordering = ('-id',)

