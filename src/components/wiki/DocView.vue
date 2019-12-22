<template>
  <div class="container-fluid Box-padding">
    <div class="content-title">
      <div class="content-title-goBack" @click="$router.go(-1)">
        <i class="goBack-icon"></i>
        <span>返回</span>
      </div>
      <span class="content-title-info">文章详情</span>
    </div>
    <div class="Box">
      <div class="Box-header">
        <h3 class="Box-title">
          <span>标题: {{docObj.title}}</span>
          <span>标签: {{docObj.tag}}</span>
          <span>作者: {{docObj.author}}</span>
          <span>分类: {{kindName.name}}</span>
          <span>创建时间: {{formatDatetime(docObj.ctime)}}</span>
        </h3>
      </div>
      <div class="Box-body">
        <mavon-editor
          :value="docObj.context"
          :subfield = "props.subfield"
          :defaultOpen = "props.defaultOpen"
          :toolbarsFlag = "props.toolbarsFlag"
          :editable="props.editable"
          :scrollStyle="props.scrollStyle"
          :boxShadow="props.boxShadow"
          style="min-height: 600px">
        </mavon-editor>
      </div>
    </div>
  </div>
</template>
<script>
import dateFormat from '../../libs/formatDatetime.js'
import { mavonEditor } from 'mavon-editor'
import 'mavon-editor/dist/css/index.css'

export default {
  data () {
    return {
      docObj: '',
      kindName: {}
    }
  },
  components: {
    mavonEditor
  },
  methods: {
    doGet (id) {
      let url = '/api/wiki/docs/?id=' + id
      this.$http.get(url).then(response => {
        this.docObj = response.res
        this.kindName = this.docObj.kind
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    formatDatetime (ctime) {
      let date = new Date(ctime)
      return dateFormat.formatDate(date, 'yyyy-MM-dd hh:mm:ss')
    }
  },
  computed: {
    props () {
      return {
        subfield: false,
        defaultOpen: 'preview',
        editable: false,
        toolbarsFlag: false,
        scrollStyle: true,
        boxShadow: false
      }
    }
  },
  created () {
    this.doGet(this.$route.params.id)
  }
}
</script>
