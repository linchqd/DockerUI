#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from celery import Celery
from app import app


def make_celery(flask_app):
    celery_app = Celery(
        flask_app.import_name,
        backend=app.config['CELERY_RESULT_BACKEND'],
        broker=flask_app.config['CELERY_BROKER_URL'],
        include=['common.tasks.task']
    )
    celery_app.conf.update(flask_app.config)

    class ContextTask(celery_app.Task):
        def __call__(self, *args, **kwargs):
            with flask_app.app_context():
                return self.run(*args, **kwargs)

    celery_app.Task = ContextTask
    return celery_app


celery = make_celery(app)
