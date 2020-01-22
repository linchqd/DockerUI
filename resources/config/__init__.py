#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from resources.config.config import Env, Conf


def add_resource(api):
    api.add_resource(Env, '/config/env/')
    api.add_resource(Conf, '/config/conf/')