#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from resources.wiki.wiki import Document, DocumentKind


def add_resource(api):
    api.add_resource(DocumentKind, '/wiki/kinds/')
    api.add_resource(Document, '/wiki/docs/')
