#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from flask import Blueprint


ws_blueprint = Blueprint('ws', __name__)


@ws_blueprint.route('webshell')
def webshell(ws):
    while not ws.closed:
        message = ws.receive()
        print(message)
        ws.send(message)