#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from flask_restful import Resource, reqparse, abort
from flask import request
from common.terminal import Terminal
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

        res = Terminal(
            host=data['ip'],
            port=data['port'],
            username=data['username'],
            password=data['password']
        ).assert_connect()

        if not res.get('res'):
            return {'message': 'Error: {}'.format(res.get('msg'))}
        data['password'] = Encryption().encrypt(data.get('password'))
        server = ServerModel(**data).save()
        return {"data": "添加成功, 服务器id: {}".format(server.id)}

    @permission_required('server_update')
    def put(self):
        parse = reqparse.RequestParser()
        data = self.add_arguments(parse).parse_args()
        server = ServerModel.query.filter_by(ip=data.get('ip')).first()
        if not server:
            return {"message": 'Error: 服务器{}is not exists'.format(data.get('ip'))}

        if data.get('password', None):
            res = Terminal(
                host=data['ip'],
                port=data['port'],
                username=data['username'],
                password=data['password']
            ).assert_connect()
            if not res.get('res'):
                return {'message': 'Error: {}'.format(res.get('msg'))}
            data['password'] = Encryption().encrypt(data.get('password'))
            server.update(**data)
        else:
            res = Terminal(
                host=data['ip'],
                port=data['port'],
                username=data['username']
            ).assert_connect()
            if not res.get('res'):
                return {'message': 'Error: {}'.format(res.get('msg'))}
            data.pop('password')
            server.update(**data)
        return {"data": "更新成功"}

    @permission_required('server_modify')
    def patch(self):
        parse = reqparse.RequestParser()
        data = self.add_arguments(parse=parse, required=False).parse_args()
        server = ServerModel.query.filter_by(ip=data['ip']).first()
        if not server:
            return {"message": 'Error: 服务器:{} is not exists'.format(data['ip'])}
        for k, v in data.items():
            if k not in ['username', 'port', 'password']:
                if hasattr(server, k) and v is not None and getattr(server, k) != v:
                    setattr(server, k, v)
            else:
                if k in ['username', 'port'] and v is not None:
                    if k == 'username':
                        res = Terminal(host=server.ip, port=server.port, username=v).assert_connect()
                    else:
                        res = Terminal(host=server.ip, port=v, username=server.username).assert_connect()
                    if not res.get('res'):
                        return {'message': 'Error: {}'.format(res.get('msg'))}
                    setattr(server, k, v)
                if k == 'password' and v is not None:
                    res = Terminal(
                        host=server.ip,
                        port=server.port,
                        username=server.username,
                        password=v
                    ).assert_connect()
                    if not res.get('res'):
                        return {'message': 'Error: {}'.format(res.get('msg'))}
                    setattr(server, k, Encryption().encrypt(v))
        server.save()
        return {"data": "修改成功"}

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
    def add_arguments(parse, required=True):
        parse.add_argument('ip', type=regex_ip, required=True, help=u'ip: 缺少该参数或格式不正确', location='json')
        parse.add_argument('port', type=int, required=required, help=u'port: 缺少该参数或格式不正确', location='json')
        parse.add_argument('username', type=str, required=required, help=u'username: 缺少该参数或格式不正确', location='json')
        parse.add_argument('password', type=str, help=u'password: 缺少该参数或格式不正确', location='json')
        parse.add_argument('desc', type=str, help=u'desc: 格式不正确', location='json')
        parse.add_argument('zone', type=str, required=required, help=u'zone: 缺少该参数或格式不正确', location='json')
        if not required:
            parse.add_argument('type', type=int, help=u'type: 缺少该参数或格式不正确', location='json')
        return parse
