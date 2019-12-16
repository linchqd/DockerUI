#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import paramiko, os
from paramiko import AuthenticationException
from threading import Thread
from resources.assets.models import ServerModel
from common.encryption import Encryption


class SSH(object):
    def __init__(
            self,
            host,
            username,
            port=22,
            password=None,
            auth_type=0,
            ws=None,
            xterm_width=135,
            xterm_height=24):
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.auth_type = auth_type
        self.ws = ws
        self.xterm_width = xterm_width
        self.xterm_height = xterm_height
        self.ssh_channel = None
        self.ssh = None

    def connect(self):
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            if self.auth_type == 1:
                self.ssh.connect(self.host, self.port, self.username, self.password, timeout=8)
                self.write_public_key()
            else:
                self.ssh.connect(self.host, self.port, self.username, password='', timeout=8)
        except AuthenticationException:
            if self.auth_type != 1:
                try:
                    server = ServerModel.query.filter_by(ip=self.host).first()
                    if server:
                        self.password = Encryption().decrypt(server.password)
                        self.ssh.connect(self.host, self.port, self.username, self.password, timeout=8)
                        self.write_public_key()
                    else:
                        return {'res': False, 'message': '服务器不存在'}
                except Exception as e:
                    return {'res': False, 'message': str(e)}
            else:
                return {'res': False, 'message': '认证失败'}
        except Exception as e:
            if self.ws:
                self.ws.send(str(e.args))
            return {'res': False, 'message': str(e)}

        if self.ws:
            self.ssh_channel = self.ssh.invoke_shell(term='xterm', height=self.xterm_height - 2, width=self.xterm_width - 2)
            self.ws.send("*" * 50 + "输入Enter进入shell" + "*" * 50 + "\r\n")

        return {'res': True}

    def write_public_key(self):
        try:
            if os.path.exists(os.environ['HOME']+'/.ssh/id_rsa.pub'):
                with open(os.environ['HOME']+'/.ssh/id_rsa.pub') as f:
                    pkey = f.read()
            else:
                os.system('ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa > /dev/null 2>&1')
                with open(os.environ['HOME']+'/.ssh/id_rsa.pub') as f:
                    pkey = f.read()
            command = 'mkdir -p -m 700 ~/.ssh/ && grep -o "{}" ~/.ssh/authorized_keys || \
            (echo "{}" >> ~/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys)'.format(pkey, pkey)
            self.ssh.exec_command(command)
        except Exception as e:
            print(str(e))

    def send_to_ssh(self, data):
        try:
            self.ssh_channel.send(data)
        except Exception as e:
            print(e.args)
            self.close()

    def send_to_ws(self):
        try:
            while not self.ssh_channel.exit_status_ready():
                recv = self.ssh_channel.recv(1024).decode('utf-8', 'ignore')
                if recv and len(recv) != 0:
                    self.ws.send(recv)
                else:
                    break
        except Exception as e:
            print(e.args)
            self.close()

    def work(self, data):
        Thread(target=self.send_to_ssh, args=(data,)).start()
        Thread(target=self.send_to_ws).start()

    def close(self):
        try:
            if self.ws:
                self.ws.close()
            if self.ssh_channel:
                self.ssh_channel.close()
        except Exception as e:
            print(e)
            pass

