<template>
  <div class="container-fluid">
    <div class="content-title">
      <span class="content-title-info">环境列表</span>
      <el-input size="mini" clearable placeholder="输入任意字段过滤" v-model="search" class="content-search"></el-input>
      <el-button type="primary" plain size="mini" @click.native="doAdd">添加</el-button>
      <el-button type="danger" plain size="mini" @click.native="doDel(selectedObj)">删除</el-button>
    </div>
    <div class="content-content">
      <el-table ref="multipleTable" @selection-change="handleSelectionChange" :data="objs.filter(searchFilter).slice((current_page - 1) * page_size, page_size * current_page)" tooltip-effect="dark" style="width: 100%">
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID"></el-table-column>
        <el-table-column prop="name" label="环境名称" show-overflow-tooltip></el-table-column>
        <el-table-column prop="desc" label="环境描述" show-overflow-tooltip></el-table-column>
        <el-table-column prop="ctime" :formatter="formatDatetime" label="创建时间" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="150">
          <template slot-scope="scope">
            <el-button size="mini" plain type="primary" @click.native="doEdit({id: scope.row.id, name: scope.row.name, desc: scope.row.desc})">编辑</el-button>
            <el-button size="mini" plain type="danger" @click="doDel([scope.row.id])">删除</el-button>
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
    <!--   dialogForm   -->
    <el-dialog :title="dialogFormTitle" :visible.sync="dialogFormVisible" :close-on-click-modal="false">
      <el-form ref="dialogForm" :model="dialogFormModel" :rules="rules" label-width="110px">
        <el-form-item prop="name" label="环境名称">
            <el-input placeholder="请输入环境名称" v-model="dialogFormModel.name" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="name" label="环境描述">
            <el-input placeholder="请输入环境描述" v-model="dialogFormModel.desc" auto-complete="off"></el-input>
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
import dateFormat from '../../libs/formatDatetime.js'

export default {
  data () {
    return {
      search: '',
      current_page: 1,
      page_size: 10,
      objs: [],
      dialogFormVisible: false,
      dialogFormTitle: '',
      dialogFormLoading: false,
      dialogFormModel: '',
      dialogFormShowObj: '',
      rules: {
        name: [
          { required: true, message: '请输入环境名称', trigger: 'blur' }
        ]
      },
      selectedObj: []
    }
  },
  methods: {
    doGet () {
      this.$http.get('/api/config/env/').then(response => {
        this.objs = response.res
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
      if (this.dialogFormShowObj === 'Add') {
        this.$refs.dialogForm.validate((pass) => {
          if (pass) {
            this.dialogFormLoading = true
            this.$http.post('/api/config/env/', this.dialogFormModel).then(response => {
              this.$custom_message('success', response.res)
              this.dialogFormVisible = false
              this.doGet()
            }, error => {
              this.$custom_message('error', error.res)
            }).finally(() => {
              this.dialogFormLoading = false
            })
          }
        })
      } else if (this.dialogFormShowObj === 'Edit') {
        this.$refs.dialogForm.validate((pass) => {
          if (pass) {
            this.dialogFormLoading = true
            this.$http.put('/api/config/env/', this.dialogFormModel).then(response => {
              this.$custom_message('success', response.res)
              this.dialogFormVisible = false
              this.doGet()
            }, error => {
              this.$custom_message('error', error.res)
            }).finally(() => {
              this.dialogFormLoading = false
            })
          }
        })
      }
    },
    doDel (ids = []) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        if (ids.length > 0) {
          this.$http.delete('/api/config/env/', { data: { 'id': ids } }).then(response => {
            this.$custom_message('success', response.res)
            this.doGet()
          }, error => {
            this.$custom_message('error', error.res)
          })
        } else {
          this.$custom_message('warning', '请选择要删除的环境!')
        }
      }).catch(() => {})
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
      this.dialogFormTitle = '添加环境'
      this.dialogFormModel = {
        name: '',
        desc: ''
      }
      this.dialogFormShowObj = 'Add'
      this.dialogFormVisible = true
    },
    doEdit (obj) {
      this.dialogFormTitle = '编辑环境'
      this.dialogFormModel = {
        name: obj.name,
        desc: obj.desc,
        id: obj.id
      }
      this.dialogFormShowObj = 'Edit'
      this.dialogFormVisible = true
    }
  },
  created () {
    this.doGet()
  }
}
</script>
