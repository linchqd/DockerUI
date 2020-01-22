#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_

from app import ma
from marshmallow import EXCLUDE, fields

from resources.config.models import Config, Environment


class EnvironmentSchema(ma.ModelSchema):

    class Meta:
        model = Environment
        unknown = EXCLUDE


class ConfigSchema(ma.ModelSchema):

    environment = fields.Nested('EnvironmentSchema', only=('id', 'name'))

    class Meta:
        model = Config
        unknown = EXCLUDE
