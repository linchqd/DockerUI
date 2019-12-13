#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import app, api, sockets
from resources import accounts
from common.prepost import init_app
from resources.assets.ws import ws_blueprint


init_app(app)
accounts.add_resource(api)
sockets.register_blueprint(ws_blueprint, url_prefix='/')

if __name__ == '__main__':
    from gevent import pywsgi, monkey
    from geventwebsocket.handler import WebSocketHandler

    monkey.patch_all()
    server = pywsgi.WSGIServer(('0.0.0.0', 8000), app, handler_class=WebSocketHandler)
    server.serve_forever()

