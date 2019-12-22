#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


from flask_restful import Resource, reqparse, request
from flask import g
from resources.wiki.Maschema import DocsKindSchema, DocsKind, Doc, DocSchema
from common.regex import int_or_list
from common.Authentication import permission_required


class Document(Resource):
    @permission_required('doc_get')
    def get(self):
        did = request.args.get('id')
        if did:
            doc = Doc.query.filter_by(id=did).first()
            if doc:
                return {"data": DocSchema().dump(doc)}
            return {"message": u"文档 {} 不存在".format(did)}, 404
        return {"data": DocSchema(many=True).dump(Doc.query.all())}

    @permission_required('doc_add')
    def post(self):
        parse = reqparse.RequestParser()
        data = self.add_arguments(parse).parse_args()
        data['author'] = g.user.name
        Doc(**data).save()
        return {"data": "添加成功"}

    @permission_required('doc_update')
    def put(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int, required=True, help=u'id: 缺少该参数或格式不正确', location='json')
        parse.add_argument('author', type=str, required=True, help=u'author: 缺少该参数或格式不正确', location='json')
        data = self.add_arguments(parse).parse_args()
        doc = Doc.query.get(data['id'])
        if not doc:
            return {"message": "文档不存在"}, 404
        doc.update(**data)
        return {"data": "修改成功"}

    @permission_required('doc_delete')
    def delete(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int_or_list, required=True, location='json')
        ids = parse.parse_args().get('id')
        docs = Doc.query.filter(Doc.id.in_(ids)).all()
        if docs:
            for doc in docs:
                doc.delete()
            return {'data': '删除成功'}
        return {"message": "文档不存在"}, 404

    @staticmethod
    def add_arguments(parse):
        parse.add_argument('title', type=str, required=True, help=u'title: 缺少该参数或格式不正确', location='json')
        parse.add_argument('tag', type=str, required=True, help=u'tag: 缺少该参数或格式不正确', location='json')
        parse.add_argument('context', type=str, required=True, help=u'context: 缺少该参数或格式不正确', location='json')
        parse.add_argument('kind_id', type=int, required=True, help=u'kind_id: 缺少该参数或格式不正确', location='json')
        return parse


class DocumentKind(Resource):
    @permission_required('kind_get')
    def get(self):
        kid = request.args.get('id')
        if kid:
            kind = DocsKind.query.filter_by(id=kid).first()
            if kind:
                return {"data": DocsKindSchema(exclude=('docs',)).dump(kind)}
            return {"message": u"分类 {} 不存在".format(kid)}, 404
        return {"data": DocsKindSchema(many=True, exclude=('docs',)).dump(DocsKind.query.all())}

    @permission_required('kind_add')
    def post(self):
        parse = reqparse.RequestParser()
        data = self.add_arguments(parse).parse_args()
        kind = DocsKind.query.filter_by(name=data['name']).first()
        if kind:
            return {"message": '分类名称: {}已存在'.format(data['name'])}

        k = DocsKind()
        k.name = data['name']
        k.save()

        return {"data": "添加成功, 分类id: {}".format(k.id)}

    @permission_required('kind_update')
    def put(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int, required=True, help=u'id: 缺少该参数或格式不正确', location='json')
        data = self.add_arguments(parse).parse_args()
        kind = DocsKind.query.get(data['id'])
        if kind:
            if kind.name != data['name']:
                if not DocsKind.query.filter_by(name=data['name']).first():
                    kind.name = data['name']
                    kind.save()
                else:
                    return {"message": '分类名称: {}已存在'.format(data['name'])}
            return {"data": "修改成功"}
        return {"message": '分类不存在'}

    @permission_required('kind_delete')
    def delete(self):
        parse = reqparse.RequestParser()
        parse.add_argument('id', type=int_or_list, required=True, location='json')
        ids = parse.parse_args().get('id')
        kinds = DocsKind.query.filter(DocsKind.id.in_(ids)).all()
        if kinds:
            for kind in kinds:
                if len(kind.docs.all()) > 0:
                    return {'data': '删除失败,分类"{}"下存在文档,请先删除文档后再删除分类'.format(kind.name)}
                kind.delete()
            return {'data': '删除成功'}
        return {"message": "分类不存在"}, 404

    @staticmethod
    def add_arguments(parse):
        parse.add_argument('name', type=str, required=True, help=u'name: 缺少该参数或格式不正确', location='json')
        return parse
