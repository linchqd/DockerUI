#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_
# pip3 install pycryptodomex


from Cryptodome.PublicKey import RSA
from Cryptodome.Cipher import PKCS1_v1_5
import binascii


def create_rsa_key():
    try:
        key = RSA.generate(2048)
        private_key = key.exportKey(pkcs=8)
        public_key = key.publickey().exportKey()
        return {
            'keys': {'public_key': public_key.decode('utf-8'), 'private_key': private_key.decode('utf-8')}
        }
    except Exception as E:
        print(E.args)
        return False


class Encryption(object):

    def __init__(self):
        self.private_key = '''-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDnHzIfaV/SZlMv
ImUMnGwwgwiRS+7tv3MaCgpgSPVLLddq67j9a8bKrruyEIIMEsAHJs1CzDOBWIBd
K2lb7GSl9x2QiJxpYwSncWkpLYDoL6+dyX1flTeq7iTC7LU+g1uUyFatlcCCvBHo
AGGSAV8joz5I1P6nK2dv7jHMh9Fj9LrymMzP0qHp9XHyZUMYqeWm4zYtJNh0q06v
a5jXvqG9wPTHFTgZGFubiyRtz03JcnZDbMbCvq1tpUIhYvZ/a5rlTjvWlqO2fPuv
U/SlwIB2FgZ7F0CpAGNhc+2g/ZUn6PEwElKzAxnRV3IdQ6a0Z5JHaIxfwYSttMhX
/4haYWQfAgMBAAECggEAA4ue9oxkmT2omQMrZFN3SryNLRgVGjXi9iChTXN7unjW
4nUAlCKgcguBeux155QsuJoHxraLM7i/1K4NzQiF+BB1C6U3gQZb0+sRdJLrdKRb
9U0EogAP/TdEqRjTJEUE6qCyyQblunECyqRMMDPahG7EoylhSVSJHwEbEnV4PihD
dKDgXd1K2NSHVcBGUidlyMjJss5ce9axeP4xTLdu59Nebs8GKXY6Khk4tjc5DOkh
QOjKAtonup7PSS85i3aBGuJfzud3X9xQ8VTn9ggqdSzwI5CRYu9/GvFlB6+tGgud
w0b1GpJwENtib7zWMEkJ0SRC/ptREwzGtqtS2eSqQQKBgQDwb52hPUuzHBSaU2WK
7Y5PPzWS4jBF1WzXX0ZsgzZGpcMexl5TrwkBc4jmCPkPCbhbcsqPVdgfs2BJQf2S
2rt+T3OZbxzIpWWEOo11hQhtcATyHmkyGwK9Dsni5+FgaAlFupxD2yLYcMXrMPAO
GH6rnXCiqSZ7uMYxDv7i0K67nQKBgQD2FTsWKd8HDIJptt1ox959O+dnTPovma6D
naQ/9fVwVTSaXxH6BR9np3xvba5eSmBCW/8uWYFlzlV2f1nUXASCFqpqZZ+kPEow
wWBPhosh9exqeQUSanSkV/gjkpB2LbI4+2OgctClCXN9TO+gIeDlbgXMdoa+rYAi
+FtAY8tn6wKBgGNrE7fnW5TdKJvDnjo7DlwwW9u3kZRestm/eKRIATpnMm5YQgrC
Vqv19QaBcVLJhySxK5bnPS2mg0rncY22yk5pVfh83F8PHRH3ECUm9BwkdLcU4hSo
3JIGOm6LyUKO4j6l8hWQ2DC9OOmOW8TIViBqQnfQD6ya88C3Xae1+Hp1AoGBAOr2
+qP+9uVUHHG0GVSjAt2xBRKtfXVV2DvzmZE42FGaCdAcVp3Tpljiov4CTCvb+G1k
ShOHgvYiPZgXoT4TXnqYCb/tqLC4oF5NRhio7tBOcJ55T052N0l0dYoBt84fc7zU
zBu3hWEP1SYe/+52aramhwLjaWVHZMH/QaIJp35hAoGBAIIHEyZC26b00oFGVWLh
PvrK9qOvh8iMpJixJYfaVfeuhX7iDD8odQ5VIcX3a2o98nQTiX+oEBuy7B2nYcgT
WsRGu3RCpyZrEEWEpmT3esKb2iPTdMLJbLAGN0nYi4W4tCGqmRYSPr00ZOwQaFiv
bF89QyYuwg8g3+D0EbVpdDJ3
-----END PRIVATE KEY-----'''
        self.public_key = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5x8yH2lf0mZTLyJlDJxs
MIMIkUvu7b9zGgoKYEj1Sy3Xauu4/WvGyq67shCCDBLABybNQswzgViAXStpW+xk
pfcdkIicaWMEp3FpKS2A6C+vncl9X5U3qu4kwuy1PoNblMhWrZXAgrwR6ABhkgFf
I6M+SNT+pytnb+4xzIfRY/S68pjMz9Kh6fVx8mVDGKnlpuM2LSTYdKtOr2uY176h
vcD0xxU4GRhbm4skbc9NyXJ2Q2zGwr6tbaVCIWL2f2ua5U471pajtnz7r1P0pcCA
dhYGexdAqQBjYXPtoP2VJ+jxMBJSswMZ0VdyHUOmtGeSR2iMX8GErbTIV/+IWmFk
HwIDAQAB
-----END PUBLIC KEY-----'''

    def encrypt(self, data):
        try:
            public_key = RSA.import_key(self.public_key)
            cipher_rsa = PKCS1_v1_5.new(public_key)
            encrypt_data = cipher_rsa.encrypt(data.encode('utf-8'))
            hex_encrypt_data = binascii.hexlify(encrypt_data).decode('utf-8')
            return hex_encrypt_data
        except Exception as err:
            print(err.args)
            return False

    def decrypt(self, hex_encrypt_data):
        try:
            private_key = RSA.import_key(self.private_key)
            cipher_rsa = PKCS1_v1_5.new(private_key)
            encrypt_data = binascii.unhexlify(hex_encrypt_data.encode('utf-8'))
            data = cipher_rsa.decrypt(encrypt_data, None).decode('utf-8')
            return data
        except Exception as E:
            print(E.args)
            return False

