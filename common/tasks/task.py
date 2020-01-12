#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from common.tasks import celery
from common.terminal import Terminal


@celery.task()
def connected(host, user, pwd, port):
    return Terminal(host=host, username=user, password=pwd, port=port).assert_connect()
