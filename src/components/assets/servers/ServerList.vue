<template>
  <div class="container-fluid">
    <div class="content-title">
      <span class="content-title-info">服务器列表</span>
      <el-input size="mini" clearable placeholder="输入任意字段过滤" v-model="search" class="content-search"></el-input>
      <el-button type="primary" plain size="mini" @click.native="doAdd">添加</el-button>
      <el-button type="danger" plain size="mini" @click.native="doDel(selectedObj)">删除</el-button>
    </div>
    <div class="content-content">
      <el-table ref="multipleTable" @selection-change="handleSelectionChange" :data="objs.filter(searchFilter).slice((current_page - 1) * page_size, page_size * current_page)" tooltip-effect="dark" style="width: 100%">
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID"></el-table-column>
        <el-table-column prop="ip" label="地址" show-overflow-tooltip></el-table-column>
        <el-table-column prop="port" label="端口" show-overflow-tooltip></el-table-column>
        <el-table-column prop="username" label="用户名" show-overflow-tooltip></el-table-column>
        <el-table-column prop="desc" label="描述" show-overflow-tooltip></el-table-column>
        <el-table-column prop="zone" label="位置" show-overflow-tooltip></el-table-column>
        <el-table-column prop="ctime" :formatter="formatDatetime" label="创建时间" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="120">
          <template slot-scope="scope">
            <el-dropdown @command="handleCommand">
              <span class="el-dropdown-link el-dropdown-link_1">
                操作菜单<i class="el-icon-arrow-down el-icon--right"></i>
              </span>
              <el-dropdown-menu slot="dropdown">
                <el-dropdown-item :command="{'opt': 'update', 'ip': scope.row.ip}" style="color:#409EFF;">更新</el-dropdown-item>
                <el-dropdown-item :command="{'opt': 'shell', 'ip': scope.row.ip}" style="color:#409EFF;">shell</el-dropdown-item>
                <el-dropdown-item :command="{'opt': 'del', 'id': scope.row.id}" style="color:#F56C6C;">删除</el-dropdown-item>
              </el-dropdown-menu>
            </el-dropdown>
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
        <el-form-item prop="ip" label="服务器地址">
            <el-input placeholder="请输入服务器地址" v-model="dialogFormModel.ip" :disabled="dialogFormShowObj === 'Update'" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="port" label="服务器端口">
            <el-input placeholder="请输入服务器端口" v-model="dialogFormModel.port" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="username" label="服务器用户名">
            <el-input placeholder="请输入用户名" v-model="dialogFormModel.username" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="password" label="服务器密码">
            <el-input placeholder="请输入服务器密码,更新服务器时可留空则不更新" type="password" v-model="dialogFormModel.password" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="desc" label="描述">
            <el-input placeholder="请输入描述/备注" v-model="dialogFormModel.desc" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="zone" label="所在位置">
            <el-input placeholder="请输入服务器所在位置" v-model="dialogFormModel.zone" auto-complete="off"></el-input>
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
import validator from '../../../libs/validator.js'

export default {
  name: 'roleList',
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
        ip: [
          { required: true, validator: validator.ip, trigger: 'blur' }
        ],
        port: [
          { required: true, validator: validator.digits, trigger: 'blur' }
        ],
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        password: [
          { message: '请输入密码', trigger: 'blur' }
        ],
        desc: [
          { message: '请输入描述/备注', trigger: 'blur' }
        ],
        zone: [
          { required: true, message: '请输入服务器所在位置', trigger: 'blur' }
        ]
      },
      selectedObj: []
    }
  },
  methods: {
    doGet () {
      this.$http.get('/api/assets/servers/').then(response => {
        this.objs = response.res
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    searchFilter (data) {
      return !this.search || data.ip.toLowerCase().includes(this.search.toLowerCase()
      ) || data.desc.toLowerCase().includes(this.search.toLowerCase()
      ) || data.zone.toLowerCase().includes(this.search.toLowerCase())
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
            this.$http.post('/api/assets/servers/', this.dialogFormModel).then(response => {
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
      } else if (this.dialogFormShowObj === 'Update') {
        this.$refs.dialogForm.validate((pass) => {
          if (pass) {
            this.dialogFormLoading = true
            this.$http.put('/api/assets/servers/', this.dialogFormModel).then(response => {
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
          this.$http.delete('/api/assets/servers/', { data: { 'id': ids } }).then(response => {
            this.$custom_message('success', response.res)
            this.doGet()
          }, error => {
            this.$custom_message('error', error.res)
          })
        } else {
          this.$custom_message('warning', '请选择要删除的服务器!')
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
      this.dialogFormTitle = '添加服务器'
      this.dialogFormModel = {
        ip: '',
        port: 22,
        username: '',
        password: '',
        desc: '',
        zone: 'local'
      }
      this.dialogFormShowObj = 'Add'
      this.dialogFormVisible = true
    },
    handleCommand (command) {
      if (command.opt === 'del') {
        this.doDel([command.id])
      } else if (command.opt === 'shell') {
        const { href } = this.$router.resolve({
          name: 'console',
          query: {
            server: command.ip
          }
        })
        window.open(href, '_blank')
      } else if (command.opt === 'update') {
        this.objs.some((value) => {
          if (value.ip === command.ip) {
            this.dialogFormTitle = '更新服务器'
            this.dialogFormModel = this.$deepCopy(value)
            this.dialogFormShowObj = 'Update'
            this.dialogFormVisible = true
          }
        })
      }
    }
  },
  created () {
    this.doGet()
  }
}
</script>
