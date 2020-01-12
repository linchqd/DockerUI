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
MIIEowIBAAKCAQEA3msP9in16P8jc0V+lvltTOpwzxeQhJ2zKCk1kBjrgfvCOXOE
GuKvjPIlFO3DZw7bUnL0H6/ZDlCLBLZksxmSeLPhrA5+RJ+iUCwoUiFPy7l8rnkr
QF3TN+uNFxGvwAz2efmdYbnvrVjOBLWsq7z+gJDhPZyCd9y2wqLyxq0twxxJBQzs
gRknYKHe+aPisZx1bixZO1ATCHgEd0mpiK1/GutA86LrjuZTDfsSb8aLfECN9mMK
huJHaEYHey/s6z+IMnqfR8JZvhTWiPHjndQ+lr+Z5tMm5TzPd1BIbd3OAkTBfP5e
q/qqLSU2JYZpfDSsCywaAYkzHNcfOeqkkpbyrQIDAQABAoIBAQC/PVMGF+InKmky
zgggi+qc/d9tURejz2yiFXzGn4avxuajO13VOCA1kmar7hvbWvzdkZWyQSLimgJO
VP2UuWIlgpWBuRx8qL2JLc6lf5r60kwQQIMd3w6jwFcaBM0W1o5/Jk9aHeOlKvxJ
NGR5bhFuPiRNM2tC4HYMOMuCZJk6bldJr8TUv++QBey4V93ZMsHjeolKJvQP0jZ7
ndHC43KsnDJavSArSL27S0AH5B4BlptBpvogwJPM7yc41pgHOt3SX3i7NVAudxQM
AwnL9gPBsGpSUgux4DxZD8uqKswdwcmJH6tnKJmT4M4XmVJRYJPSb58CHLgjzA4e
2cNw2m4BAoGBAO9ko4yTP87ZOOB2N45Wf7jp+zuIkqP+W4cLetSq2lpsABNngDlA
JChxzadZ8f03kBr4Bnz+hM5Bjqyg3jImxbWEfPnenLSB4V5YbpbHlND/If+7WVU1
CdlV8PHv/z4cvPDY05ZHHbKjKvU1VO3zwnNqKv/CGnkldurImCEScXrtAoGBAO3Y
97SlLymN3RMORhgu4OZR/5ySrJP/hAPlTjPuStYItAe6GGE0GtnYBdxR3H0D5MpK
l7REj8oVRELNUWOyTLcGbcEOehptpEeg67oqP9REJCFpocnkjaYDOWQhShEyq/QZ
ngTd+v45YeO2nha19pvfF4nfESEzK5shGhjRd57BAoGAFkR2Mg1AUi1CbR6R7Ft/
ZePdypvZiAeQ2+7lbgK2bNK+7w8hjjG5K0nqpzZmm/cfIGMRt261S7otW0Fbaa7R
lSDNvzBFw0SRggUXxE6sOQSCVRdIJ/TXBbBIyThZtZ1WtdB1XfUffg5PYJ+lVrzl
yXaGqWOUstAZT515CRp+E8ECgYBS6qOYH0nsw58BaKV5Asa2pHlm3R86zQX50bPM
mNMQAKK6Wt7q7B48OXn5j7Q9BOF6wDxYxNoXyggs/aTVC7CA0cXrWp+onPZ7Xhcv
pFDyL/skhs23M21KJa+ZP52xlyepBlE3Qyef/uMoXl6IblEVj9WF4/T1zP/zqbuO
UV/RQQKBgHM2aC6Y6aPUaTzZQkc4QqlJg5IOFCNt28MN74K8N6WM9tYYK/LOQcxN
vL2LX2jwwc4k/ITELfVFFel4q/uXyyKlFOsyMd8UJKkRC4bn1O0cLJov7Jwdi2ZA
it1qLMh8HJ4+sj2vrG2Ple4+18Q4eYFEi6hNZmaWsph1ZQI4K9jc
-----END RSA PRIVATE KEY-----'''
        return paramiko.RSAKey(file_obj=StringIO(pkey))

    def write_public_key(self):
        pkey = '''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeaw/2KfXo/yNzRX6W+W1M6nDPF5CEnbMoKTWQGOuB+8I5c4Qa4q+M8iUU7cNnDttScvQfr9kOUIsEtmSzGZJ4s+GsDn5En6JQLChSIU/LuXyueStAXdM3640XEa/ADPZ5+Z1hue+tWM4EtayrvP6AkOE9nIJ33LbCovLGrS3DHEkFDOyBGSdgod75o+KxnHVuLFk7UBMIeAR3SamIrX8a60DzouuO5lMN+xJvxot8QI32YwqG4kdoRgd7L+zrP4gyep9Hwlm+FNaI8eOd1D6Wv5nm0yblPM93UEht3c4CRMF8/l6r+qotJTYlhml8NKwLLBoBiTMc1x856qSSlvKt'''
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

