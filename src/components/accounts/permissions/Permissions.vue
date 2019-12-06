<template>
  <div class="container-fluid">
    <div class="content-title">
      <span class="content-title-info">权限列表</span>
      <el-input size="mini" clearable placeholder="输入任意字段过滤" v-model="search" class="content-search"></el-input>
    </div>
    <div class="content-content">
      <el-table ref="multipleTable" :data="allPermissions.filter(searchFilter).slice((current_page - 1) * page_size, page_size * current_page)" tooltip-effect="dark" style="width: 100%">
        <el-table-column prop="id" label="ID"></el-table-column>
        <el-table-column prop="name" label="权限名称" show-overflow-tooltip></el-table-column>
        <el-table-column prop="desc" label="权限描述" show-overflow-tooltip></el-table-column>
        <el-table-column prop="ctime" :formatter="formatDatetime" label="创建时间" show-overflow-tooltip></el-table-column>
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
      :total="allPermissions.filter(searchFilter).length">
      </el-pagination>
    </div>
  </div>
</template>
<script>
import dateFormat from '../../../libs/formatDatetime.js'

export default {
  name: 'Permissions',
  data () {
    return {
      search: '',
      current_page: 1,
      page_size: 10,
      allPermissions: []
    }
  },
  methods: {
    get_permissions () {
      this.$http.get('/api/accounts/permissions/').then(response => {
        this.allPermissions = response.res
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    searchFilter (data) {
      return !this.search || data.name.toLowerCase().includes(this.search.toLowerCase()
      ) || data.desc.toLowerCase().includes(this.search.toLowerCase())
    },
    handleSizeChange (pagesize) {
      this.page_size = pagesize
    },
    handleCurrentChange (currentPage) {
      this.current_page = currentPage
    },
    formatDatetime (row) {
      let date = new Date(row.ctime)
      return dateFormat.formatDate(date, 'yyyy-MM-dd hh:mm:ss')
    }
  },
  created () {
    this.get_permissions()
  }
}
</script>
