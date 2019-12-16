#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from flask_restful import Resource, reqparse, abort
from flask import request
from common.ssh import SSH
from common.encryption import Encryption
from common.Authentication import permission_required
from common.regex import regex_ip, int_or_list
from resources.assets.Maschema import ServerSchema, ServerModel


class Server(Resource):

    @staticmethod
    @permission_required('server_get')
    def get():
        ip = request.args.get('ip')
        if ip:
            server = ServerModel.query.filter_by(ip=ip).first()
            if server:
                return {"data": ServerSchema(exclude=('password', 'type')).dump(server)}
            abort(404, message=u"server {} is not exist".format(ip))
        return {"data": ServerSchema(many=True, exclude=('password', 'type')).dump(ServerModel.query.all())}

    @permission_required('server_add')
    def post(self):
        parse = reqparse.RequestParser()
        data = self.add_arguments(parse).parse_args()
        server = ServerModel.query.filter_by(ip=data['ip']).first()
        if server:
            return {"message": 'ip: {}已存在'.format(data['ip'])}
        ssh = SSH(
            host=data.get('ip'),
            username=data.get('username'),
            port=data.get('port'),
            password=data.get('password'),
            auth_type=1
        )
        auth = ssh.connect()
        if auth.get('res'):
            data['password'] = Encryption().encrypt(data.get('password'))
            server = ServerModel(**data).save()
            ssh.close()
            return {"data": "添加成功, 服务器id: {}".format(server.id)}
        else:
            return {"message": 'Error: {}'.format(auth.get('message'))}

    @permission_required('server_update')
    def put(self):
        pass

    @permission_required('server_modify')
    def patch(self):
        pass

    @permission_required('server_delete')
    def delete(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int_or_list, required=True, location='json')
        ids = parse.parse_args().get('id')
        servers = ServerModel.query.filter(ServerModel.id.in_(ids)).all()
        if servers:
            for server in servers:
                server.delete()
            return {'data': '删除成功'}
        abort(404, message="server is not exists")

    @staticmethod
    def add_arguments(parse):
        parse.add_argument('ip', type=regex_ip, required=True, help=u'ip: 缺少该参数或格式不正确', location='json')
        parse.add_argument('port', type=int, required=True, help=u'port: 缺少该参数或格式不正确', location='json')
        parse.add_argument('username', type=str, required=True, help=u'username: 缺少该参数或格式不正确', location='json')
        parse.add_argument('password', type=str, required=True, help=u'password: 缺少该参数或格式不正确', location='json')
        parse.add_argument('desc', type=str, help=u'desc: 格式不正确', location='json')
        parse.add_argument('zone', type=str, required=True, help=u'zone: 缺少该参数或格式不正确', location='json')
        return parse
