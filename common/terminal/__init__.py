#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import paramiko
import os
import subprocess
from paramiko import AuthenticationException
from io import StringIO
from threading import Thread
from resources.assets.models import ServerModel
from common.encryption import Encryption
from common.terminal.models import SshKeyModel


class Terminal(object):

    def __init__(
            self,
            host,
            username,
            port=22,
            password=None,
            auth_type=0,
            ws=None,
            xterm_width=135,
            xterm_height=24
    ):
        self.key_location = '~/.pkey'
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

    def assert_connect(self):
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            if self.password:
                self.ssh.connect(
                    hostname=self.host,
                    port=self.port,
                    username=self.username,
                    password=self.password,
                    timeout=8
                )
            else:
                self.ssh.connect(
                    hostname=self.host,
                    port=self.port,
                    username=self.username,
                    pkey=self.get_pkey(),
                    timeout=8
                )
            command = 'mkdir -p -m 700 ~/.ssh/ && grep -o "{}" ~/.ssh/authorized_keys || \
                        (echo "{}" >> ~/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys)'.format(
                self.get_pubkey(), self.get_pubkey())
            self.ssh.exec_command(command)
            self.ssh.close()
            self.get_pubkey()
            return {"res": True}
        except Exception as e:
            return {"res": False, "msg": str(e)}

    def connect(self):
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            # 使用秘钥连接
            self.ssh.connect(
                hostname=self.host,
                port=self.port,
                username=self.username,
                pkey=self.get_pkey(),
                timeout=8
            )
        except AuthenticationException:
            # 秘钥连接失败时尝试密码连接
            server = ServerModel.query.filter_by(ip=self.host).first()
            if server:
                try:
                    self.password = Encryption().decrypt(server.password)
                    self.ssh.connect(
                        hostname=self.host,
                        port=self.port,
                        username=self.username,
                        password=self.password,
                        timeout=8
                    )
                except Exception as e:
                    return {'res': False, 'message': str(e)}
            else:
                return {'res': False, 'message': 'ssh验证失败'}
        except Exception as e:
            return {'res': False, 'message': str(e)}

        if self.ws:
            self.ssh_channel = self.ssh.invoke_shell(
                term='xterm',
                height=self.xterm_height - 2,
                width=self.xterm_width - 2
            )
            self.ws.send("\x1B[1;3;31m*" * 50 + "欢迎使用webTerminal! 请输入Enter进入终端"
                         + "*" * 50 + "\x1B[0m\r\n")
        return {'res': True}

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

    @staticmethod
    def get_pubkey():
        ssh_key = SshKeyModel.query.filter_by(name='ssh_key').first()
        if not ssh_key:
            try:
                pkey_location = os.environ['HOME']+'/.pkey'
                if os.path.exists(pkey_location):
                    clean_file = 'rm -rf {}'.format(pkey_location+'*')
                    subprocess.run(clean_file, shell=True)
                create_file = 'ssh-keygen -t rsa -P "" -f {} > /dev/null 2>&1'.format(pkey_location)
                subprocess.run(create_file, shell=True)
                change_permission = 'chmod 600 {}'.format(pkey_location)
                subprocess.run(change_permission, shell=True)
                with open(os.environ['HOME'] + '/.pkey') as f:
                    pkey = f.read()
                with open(os.environ['HOME']+'/.pkey.pub', 'r+') as f:
                    pub_key = ' '.join(f.read().split()[0:2])
                    f.seek(0)
                    f.truncate()
                    f.write(pub_key)
                ssh_key = SshKeyModel()
                ssh_key.name = 'ssh_key'
                ssh_key.pkey = pkey
                ssh_key.pub_key = pub_key
                ssh_key.save()
            except Exception as e:
                print(str(e))
                return ''
        return ssh_key.pub_key

    @staticmethod
    def get_pkey():
        if os.path.exists(os.environ['HOME']+'/.pkey'):
            return paramiko.RSAKey.from_private_key_file(os.environ['HOME']+'/.pkey')
        else:
            ssh_key = SshKeyModel.query.filter_by(name='ssh_key').first()
            with open(os.environ['HOME'] + '/.pkey', 'w') as f:
                f.write(ssh_key.pkey)
            return paramiko.RSAKey(file_obj=StringIO(ssh_key.pkey))
