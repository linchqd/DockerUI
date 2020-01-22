#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from flask_restful import Resource, reqparse, request
from resources.config.Maschema import Config, Environment, ConfigSchema, EnvironmentSchema
from common.Authentication import permission_required
from common.regex import int_or_list
from app import app
from flask import g


class Env(Resource):
    @permission_required('env_get')
    def get(self):
        eid = request.args.get('id')
        if eid:
            env = Environment.query.filter_by(id=eid).first()
            if env:
                return {"data": EnvironmentSchema().dump(env)}
            return {"message": u"Environment id {} 不存在".format(eid)}, 404
        return {"data": EnvironmentSchema(many=True).dump(Environment.query.all())}

    @permission_required('env_add')
    def post(self):
        parse = reqparse.RequestParser()
        parse.add_argument('name', type=str, required=True, help=u'name: 缺少该参数或格式不正确', location='json')
        parse.add_argument('desc', type=str, required=True, help=u'desc: 缺少该参数或格式不正确', location='json')
        data = parse.parse_args()
        Environment(**data).save()
        return {"data": "添加成功"}

    @permission_required('env_modify')
    def put(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int, required=True, help=u'id: 缺少该参数或格式不正确', location='json')
        parse.add_argument('name', type=str, required=True, help=u'name: 缺少该参数或格式不正确', location='json')
        parse.add_argument('desc', type=str, required=True, help=u'desc: 缺少该参数或格式不正确', location='json')
        data = parse.parse_args()
        env = Environment.query.get(data['id'])
        if env:
            if env.name != data['name']:
                if not Environment.query.filter_by(name=data['name']).first():
                    env.name = data['name']
                    env.desc = data['desc']
                    env.save()
                else:
                    return {"message": '环境名称: {}已存在'.format(data['name'])}
            return {"data": "修改成功"}
        return {"message": '环境不存在'}

    @permission_required('env_delete')
    def delete(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int_or_list, required=True, location='json')
        ids = parse.parse_args().get('id')
        envs = Environment.query.filter(Environment.id.in_(ids)).all()
        if envs:
            for env in envs:
                if len(env.confs.all()) > 0:
                    return {'message': '删除环境失败,环境"{}"下存在配置,请先删除配置后再删除环境'.format(env.name)}
                env.delete()
                app.logger.info("user: {} delete env({})".format(g.user.name, env.name))
            return {'data': '删除成功'}
        return {"message": "环境id不存在"}, 404


class Conf(Resource):
    def get(self):
        pass

    def post(self):
        pass

    def put(self):
        pass

    def delete(self):
        pass