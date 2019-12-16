#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import paramiko
from paramiko import AuthenticationException
from io import StringIO
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
                # 使用密码连接,用于新增或更新服务器时验证密码是否正确
                self.ssh.connect(self.host, self.port, self.username, self.password, timeout=8)
                self.write_public_key()
            else:
                # 使用秘钥连接,用于webTerminal连接
                self.ssh.connect(self.host, self.port, self.username, pkey=self.get_pkey(), timeout=8)
        except AuthenticationException:
            if self.auth_type != 1:
                # 秘钥连接失败时尝试密码连接
                server = ServerModel.query.filter_by(ip=self.host).first()
                if server:
                    try:
                        self.password = Encryption().decrypt(server.password)
                        self.ssh.connect(self.host, self.port, self.username, self.password, timeout=8)
                        self.write_public_key()
                    except Exception as e:
                        return {'res': False, 'message': str(e)}
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

    @staticmethod
    def get_pkey():
        pkey = '''-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAsR/9pUwGRBPcQ36ypvEqAYq7dmyLLd3jQ7mLjbO6TdqYGt6z
EwkALkWckfrn1sHu41WddZ4zdbipAFkDfU7OOQYAEb0He9ntFMI1FCBcP8iCKxvx
AQ4x0YlorwIFefdNYHHdeAvYBoLu6PvUug8iwQma2k6bW/NMqO8vPArvA+NOg3JN
A4yHqlCoo1K4nMMO8HV8R0NEfdYzvTLob7Z8TiI8nguhoA2LaqyL5roaZD06V8fG
hK21SNOs+K7gXpFUDI53r6Sq+q6vbkK1sq8tRIJuzJlFVtEo9v45oddPg4BJ4I+5
VO00B100vt+93/IB2C1jyX4Zr5yAyIzjyDPolQIDAQABAoIBAEl2yU873wVxb1QX
QqX3NML69ZHCp19YvqAiXv1g5A7ScXADmiZ0/zwx5ySs+meafCiSJALaoOFcu8vH
H6ljfCkukezJiEcYNjr76eP1IA3cbhDPQAB+EK+l3GNp5TeXGOK9l2vpDap1t/2u
JaceC/4gq7eMDufuW4dd3St8JXJorktWbcjik7wx4/UATQ12eyM0KuEB+45r9HPi
1VxrGUkvIVgOSiBLyYftnkZ9NrQJGk5RGgzfHJZ2j0B942vVAogO5hrMPPiuLGlL
L+u3LH1DFzgWIYkZTUE8lH4XA9LWxQLE8Q2UAdnzndyvj5ihkrYF64AwXdu0QVkW
BvOOPQECgYEA1yoE5+MkIhCNavucg6RXpppEA5ChYlaDuir1Jz1Fuwl1appZPY5l
j+Bs2FHpR3rKag2cABAI1hZJtpwHYYG/QKIQigEZ2oIrLK6lZQqHGSTc9eXDKngZ
sXrTIK8p2gNPyHJj6W0xvVudtEwV2GfX1yy6XlFT8yayhcMte4HSZuECgYEA0r3M
KsxIaFMX8eNrXvoU3o3qqo+r4UiI3XDyJ3Ijsx6o/d9PJG96pV434fRbUE9o2J7m
n/SCujBOMsv22jhD6sunQMoAfCb2P9RICHgFMUJAhpDH4ykN8IBQVrlFJWSDiTuY
0VTzxQw/9wl2lQTQnknywLK6HRQXkpTj18TkHDUCgYEAqxyQkDVUa/7L6HO3Ef3l
cuomAsvHfGQfGDPHiPAyfz9TcHbVV53h6RzqktH5ek4NoW+3S1l1HYTWFHJbcFD1
3xnDm2yqudphKYSupf9MV1O4oZmarzCaBkoOk2SaHPYbQeauzFl5gATXEyabDOHw
hf/dKtr0r19sA/KnPhyNTiECgYAtVWrgIgXJe2aBQFzOl5l5rqm2eyWMVuAqUquk
1KbdV1EfG7SYr+qAPF5lGv2xrwNs5fHSovSkPNP1lW7KzqO9lIWsKEgmbPM4E+BT
Ag6L5CahS+/T6/b1r4SYw04elxq8oLdlAJNX5iS0bbK2p8yA4IN59HiY3MOdYq4I
snAnqQKBgQCp2mW7iHRbF8LyWU4VAEiLLZikTVyolp/blv6zYp2SCCcim1B7HEgk
CA30NlD+isnX1M9DeEQxpTFVqudP4Rf+Wysi6S7kLXRFjVF9IE1UG9Db/FMyDm1J
BZ0Cu3zbnPi0BxJ4iTYGJQs+NCrDA4qXHMOiDz0NEZbxmgymKaKTZg==
-----END RSA PRIVATE KEY-----'''
        return paramiko.RSAKey(file_obj=StringIO(pkey))

    def write_public_key(self):
        pkey = '''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxH/2lTAZEE9xDfrKm8SoBirt2bIst3eNDuYuNs7pN2pga3rMTCQAuRZyR+ufWwe7jVZ11njN1uKkAWQN9Ts45BgARvQd72e0UwjUUIFw/yIIrG/EBDjHRiWivAgV5901gcd14C9gGgu7o+9S6DyLBCZraTptb80yo7y88Cu8D406Dck0DjIeqUKijUricww7wdXxHQ0R91jO9MuhvtnxOIjyeC6GgDYtqrIvmuhpkPTpXx8aErbVI06z4ruBekVQMjnevpKr6rq9uQrWyry1Egm7MmUVW0Sj2/jmh10+DgEngj7lU7TQHXTS+373f8gHYLWPJfhmvnIDIjOPIM+iV'''
        try:
            # if os.path.exists(os.environ['HOME']+'/.ssh/id_rsa.pub'):
            #     with open(os.environ['HOME']+'/.ssh/id_rsa.pub') as f:
            #         pkey = f.read()
            # else:
            #     os.system('ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa > /dev/null 2>&1')
            #     with open(os.environ['HOME']+'/.ssh/id_rsa.pub') as f:
            #         pkey = f.read()
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

