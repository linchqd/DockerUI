import multiprocessing

bind = '127.0.0.1:8000'
workers = multiprocessing.cpu_count() * 2 + 1

backlog = 2048
worker_class = "gevent"
worker_connections = 1000
daemon = False
debug = True
proc_name = 'DockerUI_API'
pidfile = '/tmp/gunicorn.pid'
errorlog = '/tmp/gunicorn_error.log'
accesslog = '/tmp/gunicorn_access.log'
access_log_format = '%(h)s %(l)s %(u)s %(t)s'
