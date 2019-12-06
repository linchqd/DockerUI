<template>
  <div class="container-fluid">
    <div class="content-title">
      <div class="content-title-goBack" @click="$router.go(-1)">
        <i class="goBack-icon"></i>
        <span>返回</span>
      </div>
      <span class="content-title-info">用户组信息</span>
      <template v-if="$route.name === 'groups_groupEdit'">
        <el-button type="primary" plain size="mini" @click.native="updateGroup">编辑</el-button>
      </template>
    </div>
    <div class="content-content">
      <table class="table">
        <thead>
          <tr><th colspan="2">基本信息</th></tr>
        </thead>
        <tbody>
          <tr>
            <td>组ID: <span>{{ groupObj.id }}</span></td>
            <td>组描述: <span>{{ groupObj.desc }}</span></td>
          </tr>
          <tr>
            <td>组名称: <span>{{ groupObj.name }}</span></td>
            <td>创建时间: <span>{{ groupObj.ctime | formatDatetime }}</span></td>
          </tr>
        </tbody>
      </table>
      <div class="content-tabs">
        <el-tabs v-model="activeName">
          <el-tab-pane label="组成员管理" name="groupMembers">
            <div class="content-title" style="padding: 0">
              <span class="content-title-info">组成员列表</span>
              <template v-if="$route.name === 'groups_groupEdit'">
                <el-button type="primary" plain size="mini" @click.native="addMembers">添加</el-button>
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
                  <template v-if="JSON.stringify(this.groupObj.users) === '[]'">
                    <tr>
                      <td colspan="6" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in groupObj.users" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.cname }}</td>
                      <td>{{ item.phone_number }}</td>
                      <td>{{ item.email }}</td>
                      <td>
                        <el-button size="mini" plain type="primary" @click.native="goMemberDetail(item.name)">详细</el-button>
                        <template v-if="$route.name === 'groups_groupEdit'">
                          <el-button size="mini" plain type="warning" @click.native="removeMember(item.id)">移除</el-button>
                        </template>
                      </td>
                    </tr>
                  </template>
                </tbody>
              </table>
            </div>
          </el-tab-pane>
          <el-tab-pane label="关联的角色" name="hasRoles">
            <div class="content-title" style="padding: 0">
              <span class="content-title-info">角色列表</span>
              <template v-if="$route.name === 'groups_groupEdit'">
                <el-button type="primary" plain size="mini" @click.native="addRoles">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>角色名称</th>
                    <th>角色描述</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.groupObj.roles) === '[]'">
                    <tr>
                      <td colspan="4" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in groupObj.roles" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td>
                        <el-button size="mini" plain type="primary" @click.native="goRoleDetail(item.name)">详细</el-button>
                        <template v-if="$route.name === 'groups_groupEdit'">
                          <el-button size="mini" plain type="warning" @click.native="removeRole(item.id)">移除</el-button>
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
              <template v-if="$route.name === 'groups_groupEdit' && $store.getters['loginModule/getUserInfo'].is_super">
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
                    <th v-if="$route.name === 'groups_groupEdit' && $store.getters['loginModule/getUserInfo'].is_super">操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.groupObj.permissions) === '[]'">
                    <tr>
                      <td :colspan="$store.getters['loginModule/getUserInfo'].is_super ? 4 : 3" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in groupObj.permissions" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td v-if="$route.name === 'groups_groupEdit' && $store.getters['loginModule/getUserInfo'].is_super">
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
        <template v-if="dialogFormShowObj === 'updateGroup'">
          <el-form-item prop="name" label="组名称">
              <el-input placeholder="组名称" v-model="dialogFormModel.name" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item prop="desc" label="组描述">
              <el-input placeholder="组描述" v-model="dialogFormModel.desc" auto-complete="off"></el-input>
          </el-form-item>
        </template>
        <template v-else-if="dialogFormShowObj === 'addMembers'">
          <el-form-item prop="users" label="选择成员">
            <el-select v-model="memberList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择成员">
            <el-option v-for="item in dialogFormModel.users" :key="item.id" :label="item.name" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
        <template v-else-if="dialogFormShowObj === 'addRoles'">
          <el-form-item prop="roles" label="选择角色">
            <el-select v-model="roleList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择角色">
              <el-option v-for="item in dialogFormModel.roles" :key="item.id" :label="item.name" :value="item.id"></el-option>
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
      groupObj: {},
      activeName: 'groupMembers',
      dialogFormTitle: '',
      dialogFormVisible: false,
      dialogFormModel: '',
      dialogFormLoading: false,
      dialogFormShowObj: '',
      rules: {
        name: [
          { required: true, message: '请输入组名称', trigger: 'blur' }
        ],
        desc: [
          { required: true, message: '请输入组描述', trigger: 'blur' }
        ]
      },
      memberList: [],
      roleList: [],
      permissionList: []
    }
  },
  methods: {
    get_group (gName) {
      this.$http.get(`/api/accounts/groups/?name=${gName}`).then(response => {
        this.groupObj = response.res
        this.groupObj.users = this.$sortArr(this.groupObj.users, 'id')
        this.groupObj.roles = this.$sortArr(this.groupObj.roles, 'id')
        this.groupObj.permissions = this.$sortArr(this.groupObj.permissions, 'id')
        // this.userUpdateFormModel = this.$deepCopy(this.groupObj)
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    updateFunc () {
      this.$http.put('/api/accounts/groups/', this.dialogFormModel).then(response => {
        this.$custom_message('success', response.res)
        this.dialogFormVisible = false
        this.$router.push({ name: 'groups_groupEdit', params: { name: this.dialogFormModel.name } })
      }, error => {
        this.$custom_message('error', error.res)
      }).finally(() => {
        this.dialogFormLoading = false
      })
    },
    modifyFunc (data) {
      this.$http.patch('/api/accounts/groups/', data).then(response => {
        this.$custom_message('success', response.res)
        this.get_group(this.groupObj.name)
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    updateGroup () {
      this.dialogFormTitle = '更新组信息'
      this.dialogFormShowObj = 'updateGroup'
      this.dialogFormModel = this.$deepCopy(this.groupObj)
      this.dialogFormVisible = true
    },
    addMembers () {
      this.$http.get('/api/accounts/users/').then(response => {
        this.dialogFormTitle = '添加成员'
        this.dialogFormShowObj = 'addMembers'
        this.dialogFormModel = { 'users': response.res }
        this.memberList = []
        for (let key in this.groupObj.users) {
          if (this.groupObj.users.hasOwnProperty(key)) {
            this.memberList.push(this.groupObj.users[key].id)
          }
        }
        this.dialogFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removeMember (uid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.memberList = []
        for (let index in this.groupObj.users) {
          if (this.groupObj.users.hasOwnProperty(index)) {
            this.memberList.push(this.groupObj.users[index].id)
          }
        }
        delete this.memberList[this.memberList.indexOf(uid)]
        this.modifyFunc({ 'id': this.groupObj.id, 'users': this.memberList })
      }).catch(() => {})
    },
    addRoles () {
      this.$http.get('/api/accounts/roles/').then(response => {
        this.dialogFormTitle = '添加角色'
        this.dialogFormShowObj = 'addRoles'
        this.dialogFormModel = { 'roles': response.res }
        this.roleList = []
        for (let key in this.groupObj.roles) {
          if (this.groupObj.roles.hasOwnProperty(key)) {
            this.roleList.push(this.groupObj.roles[key].id)
          }
        }
        this.dialogFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removeRole (rid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.roleList = []
        for (let index in this.groupObj.roles) {
          if (this.groupObj.roles.hasOwnProperty(index)) {
            this.roleList.push(this.groupObj.roles[index].id)
          }
        }
        delete this.roleList[this.roleList.indexOf(rid)]
        this.modifyFunc({ 'id': this.groupObj.id, 'roles': this.roleList })
      }).catch(() => {})
    },
    addPermissions () {
      this.$http.get('/api/accounts/permissions/').then(response => {
        this.dialogFormTitle = '添加权限'
        this.dialogFormShowObj = 'addPermissions'
        this.dialogFormModel = { 'permissions': response.res }
        this.permissionList = []
        for (let key in this.groupObj.permissions) {
          if (this.groupObj.permissions.hasOwnProperty(key)) {
            this.permissionList.push(this.groupObj.permissions[key].id)
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
        for (let index in this.groupObj.permissions) {
          if (this.groupObj.permissions.hasOwnProperty(index)) {
            this.permissionList.push(this.groupObj.permissions[index].id)
          }
        }
        delete this.permissionList[this.permissionList.indexOf(pid)]
        this.modifyFunc({ 'id': this.groupObj.id, 'permissions': this.permissionList })
      }).catch(() => {})
    },
    dialogFormSubmit () {
      this.$refs.dialogForm.validate((pass) => {
        if (pass) {
          this.dialogFormLoading = true
          if (this.dialogFormShowObj === 'updateGroup') {
            this.updateFunc()
          } else if (this.dialogFormShowObj === 'addMembers') {
            this.modifyFunc({ 'id': this.groupObj.id, 'users': this.memberList })
          } else if (this.dialogFormShowObj === 'addRoles') {
            this.modifyFunc({ 'id': this.groupObj.id, 'roles': this.roleList })
          } else if (this.dialogFormShowObj === 'addPermissions') {
            this.modifyFunc({ 'id': this.groupObj.id, 'permissions': this.permissionList })
          }
          this.dialogFormLoading = false
          this.dialogFormVisible = false
        }
      })
    },
    goMemberDetail (name) {
      this.$router.push({ name: 'users_userInfo', params: { name: name } })
    },
    goRoleDetail (name) {
      this.$router.push({ name: 'roles_roleInfo', params: { name: name } })
    }
  },
  created () {
    this.get_group(this.$route.params.name)
  },
  watch: {
    '$route': function () {
      this.get_group(this.$route.params.name)
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
