#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_

from app import ma
from marshmallow import EXCLUDE, fields

from resources.wiki.models import DocsKind, Doc


class DocsKindSchema(ma.ModelSchema):

    class Meta:
        model = DocsKind
        unknown = EXCLUDE


class DocSchema(ma.ModelSchema):

    kind = fields.Nested('DocsKindSchema', only=('id', 'name'))

    class Meta:
        model = Doc
        unknown = EXCLUDE
