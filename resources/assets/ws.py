#!/usr/bin/env python3
# _*_ coding: utf-8 _*_


from flask import Blueprint
import paramiko, json
from threading import Thread


ws_blueprint = Blueprint('ws', __name__)


class SSH(object):
    def __init__(self, host, username, ws, xterm_width, xterm_height, auth_type=1, port=22, password=None, pkey=None):
        self.host = host
        self.username = username
        self.port = port
        self.password = password
        self.auth_type = auth_type
        self.pkey = pkey
        self.xterm_width = xterm_width
        self.xterm_height = xterm_height
        self.ssh_channel = None
        self.ws = ws

    def connect(self):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            if self.auth_type == 1:
                ssh.connect(self.host, self.port, self.username, self.password, timeout=8)
            else:
                ssh.connect(self.host, self.port, self.username, self.pkey, timeout=8)
        except Exception as e:
            self.ws.send(e.args[0])
            return False

        self.ssh_channel = ssh.invoke_shell(term='xterm', height=self.xterm_height - 2, width=self.xterm_width - 2)
        for i in range(2):
            recv = self.ssh_channel.recv(1024).decode('utf-8', 'ignore')
            self.ws.send(recv)
        return True

    def send_to_ssh(self, data):
        try:
            self.ssh_channel.send(data)
        except OSError as e:
            self.close()

    def send_to_ws(self):
        try:
            while not self.ssh_channel.exit_status_ready():
                recv = self.ssh_channel.recv(1024).decode('utf-8', 'ignore')
                if len(recv) != 0:
                    self.ws.send(recv)
                else:
                    break
        except Exception as e:
            self.ws.send(json.dumps(str(e)))
            self.close()

    def work(self, data):
        Thread(target=self.send_to_ssh, args=(data,)).start()
        Thread(target=self.send_to_ws).start()

    def close(self):
        try:
            self.ws.close()
            self.ssh_channel.close()
        except Exception as e:
            print(e)
            pass


@ws_blueprint.route('webshell')
def terminal(websocket):
    ssh = None
    data = json.loads(websocket.receive())
    if data.get('token', None) and data.get('token', None) == '123456':
        ssh = SSH(
            host=data['connect_info'].get('host', ''),
            username='root',
            password='linchqd930520',
            auth_type=2,
            xterm_width=data['connect_info'].get('xterm_width'),
            xterm_height=data['connect_info'].get('xterm_height'),
            ws=websocket
        )
        if not ssh.connect():
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
