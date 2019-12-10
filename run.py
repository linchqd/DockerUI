#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from app import app, api
from resources import accounts
from common.prepost import init_app


init_app(app)
accounts.add_resource(api)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
