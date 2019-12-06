<template>
  <div class="container-fluid">
    <div class="content-title">
      <div class="content-title-goBack" @click="$router.go(-1)">
        <i class="goBack-icon"></i>
        <span>返回</span>
      </div>
      <span class="content-title-info">角色信息</span>
      <template v-if="$route.name === 'roles_roleEdit' && $store.getters['loginModule/getUserInfo'].is_super">
        <el-button type="primary" plain size="mini" @click.native="updateRole">编辑</el-button>
      </template>
    </div>
    <div class="content-content">
      <table class="table">
        <thead>
          <tr><th colspan="2">基本信息</th></tr>
        </thead>
        <tbody>
          <tr>
            <td>角色ID: <span>{{ roleObj.id }}</span></td>
            <td>角色描述: <span>{{ roleObj.desc }}</span></td>
          </tr>
          <tr>
            <td>角色名称: <span>{{ roleObj.name }}</span></td>
            <td>创建时间: <span>{{ roleObj.ctime | formatDatetime }}</span></td>
          </tr>
        </tbody>
      </table>
      <div class="content-tabs">
        <el-tabs v-model="activeName">
          <el-tab-pane label="关联的用户" name="hasUsers">
            <div class="content-title" style="padding: 0">
              <span class="content-title-info">用户列表</span>
              <template v-if="$route.name === 'roles_roleEdit'">
                <el-button type="primary" plain size="mini" @click.native="addUsers">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>用户名称</th>
                    <th>用户姓名</th>
                    <th>手机号码</th>
                    <th>邮箱</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.roleObj.users) === '[]'">
                    <tr>
                      <td colspan="6" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in roleObj.users" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.cname }}</td>
                      <td>{{ item.phone_number }}</td>
                      <td>{{ item.email }}</td>
                      <td>
                        <el-button size="mini" plain type="primary" @click.native="goUserDetail(item.name)">详细</el-button>
                        <template v-if="$route.name === 'roles_roleEdit'">
                          <el-button size="mini" plain type="warning" @click.native="removeUser(item.id)">移除</el-button>
                        </template>
                      </td>
                    </tr>
                  </template>
                </tbody>
              </table>
            </div>
          </el-tab-pane>
          <el-tab-pane label="关联的用户组" name="hasGroups">
            <div class="content-title" style="padding: 0">
              <span class="content-title-info">用户组列表</span>
              <template v-if="$route.name === 'roles_roleEdit'">
                <el-button type="primary" plain size="mini" @click.native="addGroups">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>组名称</th>
                    <th>组描述</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.roleObj.groups) === '[]'">
                    <tr>
                      <td colspan="4" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in roleObj.groups" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td>
                        <el-button size="mini" plain type="primary" @click.native="goGroupDetail(item.name)">详细</el-button>
                        <template v-if="$route.name === 'roles_roleEdit'">
                          <el-button size="mini" plain type="warning" @click.native="removeGroup(item.id)">移除</el-button>
                        </template>
                      </td>
                    </tr>
                  </template>
                </tbody>
              </table>
            </div>
          </el-tab-pane>
          <el-tab-pane label="拥有的权限" name="hasPermissions">
            <div class="content-title" style="padding: 0">
              <span class="content-title-info">权限列表</span>
              <template v-if="$route.name === 'roles_roleEdit' && $store.getters['loginModule/getUserInfo'].is_super">
                <el-button type="primary" plain size="mini" @click.native="addPermissions">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>权限名称</th>
                    <th>权限描述</th>
                    <th v-if="$route.name === 'roles_roleEdit' && $store.getters['loginModule/getUserInfo'].is_super">操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.roleObj.permissions) === '[]'">
                    <tr>
                      <td :colspan="$store.getters['loginModule/getUserInfo'].is_super ? 4 : 3" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in roleObj.permissions" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td v-if="$route.name === 'roles_roleEdit' && $store.getters['loginModule/getUserInfo'].is_super">
                        <el-button size="mini" plain type="warning" @click.native="removePermission(item.id)">移除</el-button>
                      </td>
                    </tr>
                  </template>
                </tbody>
              </table>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </div>
    <el-dialog :title="dialogFormTitle" :visible.sync="dialogFormVisible" :close-on-click-modal="false">
      <el-form ref="dialogForm" :model="dialogFormModel" :rules="rules" label-width="100px">
        <template v-if="dialogFormShowObj === 'updateRole'">
          <el-form-item prop="name" label="角色名称">
              <el-input placeholder="角色名称" v-model="dialogFormModel.name" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item prop="desc" label="角色描述">
              <el-input placeholder="角色描述" v-model="dialogFormModel.desc" auto-complete="off"></el-input>
          </el-form-item>
        </template>
        <template v-else-if="dialogFormShowObj === 'addUsers'">
          <el-form-item prop="users" label="选择用户">
            <el-select v-model="userList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择用户">
            <el-option v-for="item in dialogFormModel.users" :key="item.id" :label="item.name" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
        <template v-else-if="dialogFormShowObj === 'addGroups'">
          <el-form-item prop="groups" label="选择组">
            <el-select v-model="groupList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择组">
              <el-option v-for="item in dialogFormModel.groups" :key="item.id" :label="item.name" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
        <template v-else-if="dialogFormShowObj === 'addPermissions'">
          <el-form-item prop="permissions" label="选择权限">
            <el-select v-model="permissionList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择权限">
              <el-option v-for="item in dialogFormModel.permissions" :key="item.id" :label="item.desc" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
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
  name: 'groupEdit',
  data () {
    return {
      roleObj: {},
      activeName: 'hasUsers',
      dialogFormTitle: '',
      dialogFormVisible: false,
      dialogFormModel: '',
      dialogFormLoading: false,
      dialogFormShowObj: '',
      rules: {
        name: [
          { required: true, message: '请输入角色名称', trigger: 'blur' }
        ],
        desc: [
          { required: true, message: '请输入角色描述', trigger: 'blur' }
        ]
      },
      userList: [],
      groupList: [],
      permissionList: []
    }
  },
  methods: {
    get_role (rName) {
      this.$http.get(`/api/accounts/roles/?name=${rName}`).then(response => {
        this.roleObj = response.res
        this.roleObj.users = this.$sortArr(this.roleObj.users, 'id')
        this.roleObj.groups = this.$sortArr(this.roleObj.groups, 'id')
        this.roleObj.permissions = this.$sortArr(this.roleObj.permissions, 'id')
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    updateFunc () {
      this.$http.put('/api/accounts/roles/', this.dialogFormModel).then(response => {
        this.$custom_message('success', response.res)
        this.dialogFormVisible = false
        this.$router.push({ name: 'roles_roleEdit', params: { name: this.dialogFormModel.name } })
      }, error => {
        this.$custom_message('error', error.res)
      }).finally(() => {
        this.dialogFormLoading = false
      })
    },
    modifyFunc (data) {
      this.$http.patch('/api/accounts/roles/', data).then(response => {
        this.$custom_message('success', response.res)
        this.get_role(this.roleObj.name)
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    updateRole () {
      this.dialogFormTitle = '更新角色信息'
      this.dialogFormShowObj = 'updateRole'
      this.dialogFormModel = this.$deepCopy(this.roleObj)
      this.dialogFormVisible = true
    },
    addUsers () {
      this.$http.get('/api/accounts/users/').then(response => {
        this.dialogFormTitle = '添加用户'
        this.dialogFormShowObj = 'addUsers'
        this.dialogFormModel = { 'users': response.res }
        this.userList = []
        for (let key in this.roleObj.users) {
          if (this.roleObj.users.hasOwnProperty(key)) {
            this.userList.push(this.roleObj.users[key].id)
          }
        }
        this.dialogFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removeUser (uid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.userList = []
        for (let index in this.roleObj.users) {
          if (this.roleObj.users.hasOwnProperty(index)) {
            this.userList.push(this.roleObj.users[index].id)
          }
        }
        delete this.userList[this.userList.indexOf(uid)]
        this.modifyFunc({ 'id': this.roleObj.id, 'users': this.userList })
      }).catch(() => {})
    },
    addGroups () {
      this.$http.get('/api/accounts/groups/').then(response => {
        this.dialogFormTitle = '添加用户组'
        this.dialogFormShowObj = 'addGroups'
        this.dialogFormModel = { 'groups': response.res }
        this.groupList = []
        for (let key in this.roleObj.groups) {
          if (this.roleObj.groups.hasOwnProperty(key)) {
            this.groupList.push(this.roleObj.groups[key].id)
          }
        }
        this.dialogFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removeGroup (gid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.groupList = []
        for (let index in this.roleObj.groups) {
          if (this.roleObj.groups.hasOwnProperty(index)) {
            this.groupList.push(this.roleObj.groups[index].id)
          }
        }
        delete this.groupList[this.groupList.indexOf(gid)]
        this.modifyFunc({ 'id': this.roleObj.id, 'groups': this.groupList })
      }).catch(() => {})
    },
    addPermissions () {
      this.$http.get('/api/accounts/permissions/').then(response => {
        this.dialogFormTitle = '添加权限'
        this.dialogFormShowObj = 'addPermissions'
        this.dialogFormModel = { 'permissions': response.res }
        this.permissionList = []
        for (let key in this.roleObj.permissions) {
          if (this.roleObj.permissions.hasOwnProperty(key)) {
            this.permissionList.push(this.roleObj.permissions[key].id)
          }
        }
        this.dialogFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removePermission (pid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.permissionList = []
        for (let index in this.roleObj.permissions) {
          if (this.roleObj.permissions.hasOwnProperty(index)) {
            this.permissionList.push(this.roleObj.permissions[index].id)
          }
        }
        delete this.permissionList[this.permissionList.indexOf(pid)]
        this.modifyFunc({ 'id': this.roleObj.id, 'permissions': this.permissionList })
      }).catch(() => {})
    },
    dialogFormSubmit () {
      this.$refs.dialogForm.validate((pass) => {
        if (pass) {
          this.dialogFormLoading = true
          if (this.dialogFormShowObj === 'updateRole') {
            this.updateFunc()
          } else if (this.dialogFormShowObj === 'addUsers') {
            this.modifyFunc({ 'id': this.roleObj.id, 'users': this.userList })
          } else if (this.dialogFormShowObj === 'addGroups') {
            this.modifyFunc({ 'id': this.roleObj.id, 'groups': this.groupList })
          } else if (this.dialogFormShowObj === 'addPermissions') {
            this.modifyFunc({ 'id': this.roleObj.id, 'permissions': this.permissionList })
          }
          this.dialogFormLoading = false
          this.dialogFormVisible = false
        }
      })
    },
    goUserDetail (name) {
      this.$router.push({ name: 'users_userInfo', params: { name: name } })
    },
    goGroupDetail (name) {
      this.$router.push({ name: 'groups_groupInfo', params: { name: name } })
    }
  },
  created () {
    this.get_role(this.$route.params.name)
  },
  watch: {
    '$route': function () {
      this.get_role(this.$route.params.name)
    }
  },
  filters: {
    formatDatetime: (time) => {
      let date = new Date(time)
      return dateFormat.formatDate(date, 'yyyy-MM-dd hh:mm:ss')
    }
  }
}
</script>
