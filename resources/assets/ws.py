#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from flask import Blueprint
import json
from common.ssh import SSH


ws_blueprint = Blueprint('ws', __name__)


@ws_blueprint.route('webTerminal/')
def terminal(websocket):
    ssh = None
    data = json.loads(websocket.receive())
    if data.get('token', None) and data.get('token', None) == '123456':
        ssh = SSH(
            host=data['connect_info'].get('host', ''),
            username='root',
            password='linchqd930520',
            auth_type=1,
            xterm_width=data['connect_info'].get('xterm_width'),
            xterm_height=data['connect_info'].get('xterm_height'),
            ws=websocket
        )
        if not ssh.connect().get('res'):
            websocket.close()
            return False
    else:
        websocket.send('auth failed or Permission denied!')
        websocket.close()

    while not websocket.closed:
        message = websocket.receive()
        ssh.work(message)
    else:
        ssh.close()
