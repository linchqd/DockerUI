<template>
  <div class="container-fluid">
    <div class="content-title">
      <span class="content-title-info">文档列表</span>
      <el-input size="mini" clearable placeholder="输入任意字段过滤" v-model="search" class="content-search"></el-input>
      <el-button type="primary" plain size="mini" @click.native="doAdd">添加</el-button>
      <el-button type="danger" plain size="mini" @click.native="doDel(selectedObj)">删除</el-button>
    </div>
    <div class="content-content">
      <el-table ref="multipleTable" @selection-change="handleSelectionChange" :data="objs.filter(searchFilter).slice((current_page - 1) * page_size, page_size * current_page)" tooltip-effect="dark" style="width: 100%">
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID"></el-table-column>
        <el-table-column prop="title" label="标题" show-overflow-tooltip></el-table-column>
        <el-table-column prop="tag" label="标签" show-overflow-tooltip></el-table-column>
        <el-table-column prop="author" label="作者" show-overflow-tooltip></el-table-column>
        <el-table-column prop="kind.name" label="分类" show-overflow-tooltip></el-table-column>
        <el-table-column prop="ctime" :formatter="formatDatetime" label="创建时间" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="150">
          <template slot-scope="scope">
            <el-button size="mini" plain type="primary" @click.native="doEdit(scope.row.id)">编辑</el-button>
            <el-button size="mini" plain type="primary" @click="doView(scope.row.id)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
    <div class="content-pagination">
      <el-pagination
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      :current-page="current_page"
      :page-sizes="[10, 20, 50, 100]"
      :page-size="page_size"
      layout="total, sizes, prev, pager, next, jumper"
      :total="objs.filter(searchFilter).length">
      </el-pagination>
    </div>
  </div>
</template>
<script>
import dateFormat from '../../libs/formatDatetime.js'

export default {
  name: 'DocList',
  data () {
    return {
      search: '',
      current_page: 1,
      page_size: 10,
      objs: [],
      selectedObj: []
    }
  },
  methods: {
    doGet () {
      this.$http.get('/api/wiki/docs/').then(response => {
        this.objs = response.res
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    searchFilter (data) {
      return !this.search || data.title.toLowerCase().includes(this.search.toLowerCase()
      ) || data.tag.toLowerCase().includes(this.search.toLowerCase()
      ) || data.author.toLowerCase().includes(this.search.toLowerCase()
      ) || data.kind.name.toLowerCase().includes(this.search.toLowerCase())
    },
    handleSizeChange (pagesize) {
      this.page_size = pagesize
    },
    handleCurrentChange (currentPage) {
      this.current_page = currentPage
    },
    doDel (ids = []) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        if (ids.length > 0) {
          this.$http.delete('/api/wiki/docs/', { data: { 'id': ids } }).then(response => {
            this.$custom_message('success', response.res)
            this.doGet()
          }, error => {
            this.$custom_message('error', error.res)
          })
        } else {
          this.$custom_message('warning', '请选择要删除的文档!')
        }
      }).catch(() => {})
    },
    doView (id) {
      this.$router.push({ name: 'docs_View', params: { id: id } })
    },
    doEdit (id) {
      this.$router.push({ name: 'docs_Edit', params: { id: id } })
    },
    handleSelectionChange (val) {
      this.selectedObj = []
      for (let i = 0; i < val.length; i++) {
        if (this.selectedObj.indexOf(val[i].id) === -1) {
          this.selectedObj.push(val[i].id)
        }
      }
    },
    formatDatetime (row) {
      let date = new Date(row.ctime)
      return dateFormat.formatDate(date, 'yyyy-MM-dd hh:mm:ss')
    },
    doAdd () {
      this.$router.push({ name: 'docs_Add' })
    }
  },
  created () {
    this.doGet()
  }
}
</script>
