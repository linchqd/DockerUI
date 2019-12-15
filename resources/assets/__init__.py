#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from resources.assets.server import Server


def add_resource(api):
    api.add_resource(Server, '/assets/servers/')
