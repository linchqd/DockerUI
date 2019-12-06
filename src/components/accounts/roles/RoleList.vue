<template>
  <div class="container-fluid">
    <div class="content-title">
      <span class="content-title-info">角色列表</span>
      <el-input size="mini" clearable placeholder="输入任意字段过滤" v-model="search" class="content-search"></el-input>
      <el-button type="primary" plain size="mini" @click.native="dialogFormVisible = true">添加</el-button>
      <el-button type="danger" plain size="mini" @click.native="deleteRoles(selectedRoles)">删除</el-button>
    </div>
    <div class="content-content">
      <el-table ref="multipleTable" @selection-change="handleSelectionChange" :data="allRoles.filter(searchFilter).slice((current_page - 1) * page_size, page_size * current_page)" tooltip-effect="dark" style="width: 100%">
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID"></el-table-column>
        <el-table-column prop="name" label="角色名称" show-overflow-tooltip></el-table-column>
        <el-table-column prop="desc" label="角色描述" show-overflow-tooltip></el-table-column>
        <el-table-column prop="ctime" :formatter="formatDatetime" label="创建时间" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button size="mini" plain type="primary" @click="goEdit(scope.row)">管理</el-button>
            <el-button size="mini" plain type="danger" @click="deleteRoles([scope.row.id])">删除</el-button>
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
      :total="allRoles.filter(searchFilter).length">
      </el-pagination>
    </div>
    <!--   dialogForm   -->
    <el-dialog :title="dialogFormTitle" :visible.sync="dialogFormVisible" :close-on-click-modal="false">
        <el-form ref="dialogForm" :model="dialogFormModel" :rules="rules" label-width="100px">
          <el-form-item prop="name" label="角色名称">
              <el-input placeholder="角色名称" v-model="dialogFormModel.name" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item prop="desc" label="角色描述">
              <el-input placeholder="角色描述" v-model="dialogFormModel.desc" auto-complete="off"></el-input>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button type="danger" size="small" plain @click.native="dialogFormVisible = false">取 消</el-button>
          <el-button type="primary" size="small" :loading="dialogFormLoading" plain @click.native="dialogFormSubmit">确 定</el-button>
        </div>
      </el-dialog>
  </div>
</template>
<script>
import dateFormat from '../../../libs/formatDatetime.js'

export default {
  name: 'roleList',
  data () {
    return {
      search: '',
      current_page: 1,
      page_size: 10,
      allRoles: [],
      dialogFormVisible: false,
      dialogFormTitle: '添加角色',
      dialogFormLoading: false,
      dialogFormModel: {
        name: '',
        desc: ''
      },
      rules: {
        name: [
          { required: true, message: '请输入角色名称', trigger: 'blur' }
        ],
        desc: [
          { required: true, message: '请输入角色描述', trigger: 'blur' }
        ]
      },
      selectedRoles: []
    }
  },
  methods: {
    get_roles () {
      this.$http.get('/api/accounts/roles/').then(response => {
        this.allRoles = response.res
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
    dialogFormSubmit () {
      this.$refs.dialogForm.validate((pass) => {
        if (pass) {
          this.dialogFormLoading = true
          this.$http.post('/api/accounts/roles/', this.dialogFormModel).then(response => {
            this.$custom_message('success', response.res)
            this.dialogFormVisible = false
            this.get_roles()
          }, error => {
            this.$custom_message('error', error.res)
          }).finally(() => {
            this.dialogFormLoading = false
          })
        }
      })
    },
    deleteRoles (ids = []) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        if (ids.length > 0) {
          this.$http.delete('/api/accounts/roles/', { data: { 'id': ids } }).then(response => {
            this.$custom_message('success', response.res)
            this.get_roles()
          }, error => {
            this.$custom_message('error', error.res)
          })
        } else {
          this.$custom_message('warning', '请选择要删除的角色!')
        }
      }).catch(() => {})
    },
    handleSelectionChange (val) {
      this.selectedRoles = []
      for (let i = 0; i < val.length; i++) {
        if (this.selectedRoles.indexOf(val[i].id) === -1) {
          this.selectedRoles.push(val[i].id)
        }
      }
    },
    goEdit (row) {
      this.$router.push({ name: 'roles_roleEdit', params: { name: row.name } })
    },
    formatDatetime (row) {
      let date = new Date(row.ctime)
      return dateFormat.formatDate(date, 'yyyy-MM-dd hh:mm:ss')
    }
  },
  created () {
    this.get_roles()
  }
}
</script>
