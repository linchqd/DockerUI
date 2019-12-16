#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import re


def regex_ip(value):
    reg = r'(([01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])\.){3}([01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])'
    if value:
        res = re.match(reg, value)
        if res:
            return value
    raise ValueError('ip地址为空或格式不正确')


def int_or_list(value, name):
    if isinstance(value, int):
        return [value]
    elif isinstance(value, list):
        return value
    raise ValueError('TypeError,{} 必须为int或者list'.format(name))
