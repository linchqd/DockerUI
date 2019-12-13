#!/usr/bin/env python3
# _*_ coding: utf-8 _*_
# gunicorn --worker-class "geventwebsocket.gunicorn.workers.GeventWebSocketWorker" -w 1 run:app -b 0.0.0.0:8000 --access-logfile -

import multiprocessing

bind = '127.0.0.1:8000'
workers = multiprocessing.cpu_count() * 2 + 1

backlog = 2048
worker_class = "geventwebsocket.gunicorn.workers.GeventWebSocketWorker"
worker_connections = 1000
daemon = False
debug = True
# proc_name = 'dockerui_api'
pidfile = '/tmp/api.pid'
errorlog = '/tmp/api_error.log'
accesslog = '/tmp/api_access.log'
loglevel = 'info'
access_log_format = '%(t)s %(p)s %(h)s %(u)s %(r)s %(s)s %(D)s %(U)s %(q)s'