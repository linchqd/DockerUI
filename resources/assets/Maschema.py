#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_
"""
获取sqlalchemy model 字段
from sqlalchemy.orm import class_mapper
for c in class_mapper(server.__class__).columns:
    print(c.key)
"""
from app import ma
from marshmallow import EXCLUDE

from resources.assets.models import ServerModel


class ServerSchema(ma.ModelSchema):

    class Meta:
        model = ServerModel
        unknown = EXCLUDE
