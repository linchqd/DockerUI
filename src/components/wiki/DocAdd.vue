<template>
  <div class="container-fluid">
    <div class="content-title">
      <div class="content-title-goBack" @click="$router.go(-1)">
        <i class="goBack-icon"></i>
        <span>返回</span>
      </div>
      <span class="content-title-info">{{title}}</span>
    </div>
    <div class="content-content">
      <el-form ref="Form" :model="FormModel" :rules="rules" :inline="true" size="small">
        <el-form-item prop="title" label="文章标题">
            <el-input placeholder="文章标题" v-model="FormModel.title" auto-complete="off" style="width: 360px"></el-input>
        </el-form-item>
        <el-form-item prop="tag" label="标签">
            <el-input placeholder="标签" v-model="FormModel.tag" style="width: 180px" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="kind_id" label="分类">
          <el-select v-model="FormModel.kind_id" clearable filterable size="small" style="width: 150px;" placeholder="选择分类">
            <el-option v-for="item in kindObj" :key="item.id" :label="item.name" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-button type="primary" size="small" :loading="FormLoading" plain @click.native="FormSubmit">提 交</el-button>
        <mavon-editor v-model="FormModel.context" class="md" :codeStyle="code_style" style="min-height: 600px"/>
      </el-form>
    </div>
  </div>
</template>
<script>
import { mavonEditor } from 'mavon-editor'
import 'mavon-editor/dist/css/index.css'

export default {
  name: 'addWiki',
  data () {
    return {
      title: '添加文档',
      FormLoading: false,
      FormShowObj: '',
      FormModel: {
        title: '',
        tag: '',
        context: '',
        kind_id: ''
      },
      rules: {
        title: [ { required: true, message: '请输入文章标题', trigger: 'blur' } ],
        tag: [ { required: true, message: '请输入文章标签', trigger: 'blur' } ],
        context: [ { required: true, message: '请输入文章内容', trigger: 'blur' } ],
        kind_id: [ { required: true, message: '请选择分类', trigger: 'blur' } ]
      },
      kindObj: '',
      docObj: '',
      code_style: 'monokai-sublime'
    }
  },
  components: {
    mavonEditor
  },
  methods: {
    getKind () {
      this.$http.get('/api/wiki/kinds/').then(response => {
        this.kindObj = response.res
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    doGet (id) {
      let url = '/api/wiki/docs/?id=' + id
      this.$http.get(url).then(response => {
        this.docObj = response.res
        this.FormModel = this.$deepCopy(this.docObj)
        this.FormModel.kind_id = this.FormModel.kind.id
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    FormSubmit () {
      this.$refs.Form.validate((pass) => {
        if (pass) {
          this.FormLoading = true
          if (this.$route.name === 'docs_Edit') {
            this.$http.put('/api/wiki/docs/', this.FormModel).then(response => {
              this.$custom_message('success', response.res)
              this.$router.push({ name: 'docs' })
            }, error => {
              this.$custom_message('error', error.res)
            }).finally(() => {
              this.FormLoading = false
            })
          } else {
            this.$http.post('/api/wiki/docs/', this.FormModel).then(response => {
              this.$custom_message('success', response.res)
              this.$router.push({ name: 'docs' })
            }, error => {
              this.$custom_message('error', error.res)
            }).finally(() => {
              this.FormLoading = false
            })
          }
        }
      })
    }
  },
  created () {
    if (this.$route.params.hasOwnProperty('id')) {
      this.title = '编辑文档'
      this.doGet(this.$route.params.id)
    } else {
      this.title = '添加文档'
    }
    this.getKind()
  }
}
</script>
