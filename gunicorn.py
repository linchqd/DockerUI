import multiprocessing

bind = 'API_SERVER'
workers = multiprocessing.cpu_count() * 2 + 1

backlog = 2048
worker_class = "gevent"
worker_connections = 1000
daemon = False
debug = True
proc_name = 'dockerui_api'
pidfile = '/tmp/gunicorn.pid'
errorlog = '/tmp/gunicorn_error.log'
accesslog = '/tmp/gunicorn_access.log'
access_log_format = '%(t)s %(p)s %(h)s %(u)s %(r)s %(s)s %(D)s %(U)s %(q)s'
