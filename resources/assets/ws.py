#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from flask import Blueprint
import json, time
from common.ssh import SSH
from resources.accounts.models import User
from resources.assets.models import ServerModel


ws_blueprint = Blueprint('ws', __name__)


@ws_blueprint.route('webTerminal/')
def terminal(websocket):
    ssh = None
    data = json.loads(websocket.receive())
    user = User.query.filter_by(access_token=data.get('token', None)).first()
    if user and user.status and user.token_expired >= time.time() \
            and (user.is_super or 'server_webssh' in user.get_permissions()):
        server = ServerModel.query.filter_by(ip=data.get('host', None)).first()
        if server:
            ssh = SSH(
                host=server.ip,
                username=server.username,
                port=server.port,
                xterm_width=data.get('xterm_width', 135),
                xterm_height=data.get('xterm_height', 24),
                ws=websocket
            )
            if not ssh.connect().get('res'):
                websocket.close()
                return False
        else:
            websocket.send('server is not exists!')
            websocket.close()
            return False
    else:
        websocket.send('auth failed or Permission denied!')
        websocket.close()
        return False

    while not websocket.closed:
        message = websocket.receive()
        ssh.work(message)
    else:
        ssh.close()
