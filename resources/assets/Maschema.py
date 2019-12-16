#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import ma
from marshmallow import EXCLUDE

from resources.assets.models import ServerModel


class ServerSchema(ma.ModelSchema):

    class Meta:
        model = ServerModel
        unknown = EXCLUDE
