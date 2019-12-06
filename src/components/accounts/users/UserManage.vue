<template>
  <div class="container-fluid">
    <div class="content-title">
      <div class="content-title-goBack" @click="$router.go(-1)">
        <i class="goBack-icon"></i>
        <span>返回</span>
      </div>
      <span class="content-title-info">用户信息</span>
      <template v-if="$route.name === 'users_userEdit'">
        <template v-if="$store.getters['loginModule/getUserInfo'].is_super">
          <el-button v-if="userObj.is_super" type="danger" plain size="mini" @click.native="setOrMvAdmin">移除管理员</el-button>
          <el-button v-else type="danger" plain size="mini" @click.native="setOrMvAdmin">设为管理员</el-button>
        </template>
        <el-button type="warning" plain size="mini" @click.native="resetPasswordShow">修改密码</el-button>
        <el-button v-if="userObj.status" type="danger" plain size="mini" @click.native="enableOrDisable">禁用</el-button>
        <el-button v-else type="success" plain size="mini" @click.native="enableOrDisable">启用</el-button>
        <el-button type="primary" plain size="mini" @click.native="userUpdateFromVisible = true">编辑</el-button>
      </template>
    </div>
    <div class="content-content">
      <table class="table">
        <thead>
          <tr><th colspan="3">基本信息</th></tr>
        </thead>
        <tbody>
          <tr>
            <td>用户ID: <span>{{ userObj.id }}</span></td>
            <td>邮箱: <span>{{ userObj.email }}</span></td>
            <td>状态: <span>{{ userObj.status | assertStatus }}</span></td>
          </tr>
          <tr>
            <td>用户名: <span>{{ userObj.name }}</span></td>
            <td>手机号码: <span>{{ userObj.phone_number }}</span></td>
            <td>创建时间: <span>{{ userObj.ctime | formatDatetime }}</span></td>
          </tr>
          <tr>
            <td>用户姓名: <span>{{ userObj.cname }}</span></td>
            <td>是否管理员: <span>{{ userObj.is_super | assertIsSuper }}</span></td>
            <td>最后登录时间: <span>{{ userObj.last_time | formatDatetime }}</span></td>
          </tr>
        </tbody>
      </table>
      <div class="content-tabs">
        <el-tabs v-model="activeName">
          <el-tab-pane label="用户组管理" name="hasGroups">
            <div class="content-title" style="padding: 0">
              <span class="content-title-info">用户组列表</span>
              <template v-if="$route.name === 'users_userEdit'">
              <el-button type="primary" plain size="mini" @click.native="joinGroups">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>组ID</th>
                    <th>组名称</th>
                    <th>组描述</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.userObj.groups) === '[]'">
                    <tr>
                      <td colspan="4" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in userObj.groups" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td>
                        <el-button size="mini" plain type="primary" @click.native="goGroupDetail(item.name)">详细</el-button>
                        <template v-if="$route.name === 'users_userEdit'">
                          <el-button size="mini" plain type="warning" @click.native="exitGroups(item.id)">移除</el-button>
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
              <template v-if="$route.name === 'users_userEdit'">
                <el-button type="primary" plain size="mini" @click.native="addRoles">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>角色ID</th>
                    <th>角色名称</th>
                    <th>角色描述</th>
                    <th>操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.userObj.roles) === '[]'">
                    <tr>
                      <td colspan="4" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in userObj.roles" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td>
                        <el-button size="mini" plain type="primary" @click.native="goRoleDetail(item.name)">详细</el-button>
                        <template v-if="$route.name === 'users_userEdit'">
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
              <template v-if="$route.name === 'users_userEdit' && $store.getters['loginModule/getUserInfo'].is_super">
                <el-button type="primary" plain size="mini" @click.native="addPermissions">添加</el-button>
              </template>
            </div>
            <div class="content-content">
              <table class="table noBorder">
                <thead>
                  <tr>
                    <th>权限ID</th>
                    <th>权限名称</th>
                    <th>权限描述</th>
                    <th v-if="$store.getters['loginModule/getUserInfo'].is_super && $route.name === 'users_userEdit'">操作</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-if="JSON.stringify(this.userObj.permissions) === '[]'">
                    <tr>
                      <td :colspan="$store.getters['loginModule/getUserInfo'].is_super ? 4 : 3" style="text-align: center">无数据</td>
                    </tr>
                  </template>
                  <template v-else>
                    <tr v-for="(item, index) in userObj.permissions" :key="index">
                      <td>{{ item.id }}</td>
                      <td>{{ item.name }}</td>
                      <td>{{ item.desc }}</td>
                      <td v-if="$store.getters['loginModule/getUserInfo'].is_super && $route.name === 'users_userEdit'">
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
    <el-dialog :title="userUpdateFormTitle" :visible.sync="userUpdateFromVisible" :close-on-click-modal="false">
      <el-form ref="userUpdateFrom" :model="userUpdateFormModel" :rules="rules" label-width="100px">
        <el-form-item prop="name" label="登录名">
            <el-input placeholder="username" v-model="userUpdateFormModel.name" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="cname" label="姓名">
            <el-input placeholder="cname" v-model="userUpdateFormModel.cname" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="email" label="邮箱">
            <el-input placeholder="email" v-model="userUpdateFormModel.email" auto-complete="off"></el-input>
        </el-form-item>
        <el-form-item prop="phone_number" label="手机号码" required>
            <el-input placeholder="phone number" v-model="userUpdateFormModel.phone_number" auto-complete="off"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="danger" size="small" plain @click.native="userUpdateFromVisible = false">取 消</el-button>
        <el-button type="primary" size="small" :loading="userUpdateFromLoading" plain @click.native="userUpdateFromSubmit">确 定</el-button>
      </div>
    </el-dialog>
    <el-dialog :title="userModifyFormTitle" :visible.sync="userModifyFormVisible" :close-on-click-modal="false">
      <el-form ref="userModifyFrom" :model="userModifyFormModel" :rules="rules" label-width="100px">
        <template v-if="userModifyFormObj === 'resetPwd'">
          <el-form-item prop="password" label="密码">
              <el-input placeholder="密码" type="password" v-model="userModifyFormModel.password" auto-complete="off"></el-input>
          </el-form-item>
          <el-form-item prop="password2" label="确认密码">
              <el-input placeholder="确认密码" type="password" v-model="userModifyFormModel.password2" auto-complete="off"></el-input>
          </el-form-item>
        </template>
        <template v-else-if="userModifyFormObj === 'joinGroup'">
          <el-form-item prop="groups" label="选择用户组">
            <el-select v-model="joinGroupList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择用户组">
              <el-option v-for="item in userModifyFormModel.groups" :key="item.id" :label="item.name" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
        <template v-else-if="userModifyFormObj === 'addRole'">
          <el-form-item prop="roles" label="选择角色">
            <el-select v-model="hasRoleList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择角色">
              <el-option v-for="item in userModifyFormModel.roles" :key="item.id" :label="item.name" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
        <template v-else-if="userModifyFormObj === 'addPermission'">
          <el-form-item prop="permissions" label="选择权限">
            <el-select v-model="hasPermissionList" multiple clearable filterable size="small" style="width: 300px;" placeholder="选择权限">
              <el-option v-for="item in userModifyFormModel.permissions" :key="item.id" :label="item.desc" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
        </template>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="danger" size="small" plain @click.native="userModifyFormVisible = false">取 消</el-button>
        <el-button type="primary" size="small" :loading="userModifyFormLoading" plain @click.native="userModifyFromSubmit">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import dateFormat from '../../../libs/formatDatetime.js'
export default {
  name: 'userEdit',
  data () {
    let checkPhone = (rule, value, callback) => {
      if (value === '') {
        return callback(new Error('手机号不能为空'))
      }
      setTimeout(() => {
        let mobile = /^1[34578]\d{9}$/
        if (!mobile.test(value)) {
          callback(new Error('手机号不正确'))
        } else {
          callback()
        }
      }, 1000)
    }
    let validatePwd = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请输入密码'))
      } else {
        callback()
      }
    }
    let validatePwd2 = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请再次输入密码'))
      } else if (value !== this.userModifyFormModel.password) {
        callback(new Error('两次输入密码不一致!'))
      } else {
        callback()
      }
    }
    return {
      userObj: {},
      allGroups: [],
      allRoles: [],
      allPermissions: [],
      activeName: 'hasGroups',
      userUpdateFormTitle: '更新用户',
      userUpdateFormModel: '',
      userUpdateFromVisible: false,
      userUpdateFromLoading: false,
      rules: {
        name: [
          { required: true, message: '请输入登录名', trigger: 'blur' }
        ],
        cname: [
          { required: true, message: '请输入姓名', trigger: 'blur' }
        ],
        phone_number: [
          { validator: checkPhone, trigger: 'blur' }
        ],
        email: [
          { required: true, message: '请输入邮箱地址', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur,change' }
        ],
        password: [
          { validator: validatePwd, trigger: 'blur' }
        ],
        password2: [
          { validator: validatePwd2, trigger: 'blur' }
        ]
      },
      userModifyFormTitle: '',
      userModifyFormVisible: false,
      userModifyFormLoading: false,
      userModifyFormObj: '',
      userModifyFormModel: '',
      joinGroupList: [],
      hasRoleList: [],
      hasPermissionList: []
    }
  },
  methods: {
    get_users (username) {
      this.$http.get(`/api/accounts/users/?name=${username}`).then(response => {
        this.userObj = response.res
        this.userObj.groups = this.$sortArr(this.userObj.groups, 'id')
        this.userObj.roles = this.$sortArr(this.userObj.roles, 'id')
        this.userObj.permissions = this.$sortArr(this.userObj.permissions, 'id')
        this.userUpdateFormModel = this.$deepCopy(this.userObj)
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    userUpdateFromSubmit () {
      this.$refs.userUpdateFrom.validate((pass) => {
        if (pass) {
          this.userUpdateFromLoading = true
          this.$http.put('/api/accounts/users/', this.userUpdateFormModel).then(response => {
            this.$custom_message('success', response.res)
            this.userUpdateFromVisible = false
            if (this.userUpdateFormModel.name === this.userObj.name) {
              this.get_users(this.userUpdateFormModel.name)
            } else {
              this.$router.push({ name: 'users_userEdit', params: { name: this.userUpdateFormModel.name } })
            }
          }, error => {
            this.$custom_message('error', error.res)
          }).finally(() => {
            this.userUpdateFromLoading = false
          })
        }
      })
    },
    resetPasswordShow () {
      this.userModifyFormTitle = '重置密码'
      this.userModifyFormObj = 'resetPwd'
      this.userModifyFormModel = {
        password: '',
        password2: ''
      }
      this.userModifyFormVisible = true
    },
    joinGroups () {
      this.$http.get('/api/accounts/groups/').then(response => {
        this.allGroups = response.res
        this.userModifyFormTitle = '选择要加入的用户组'
        this.userModifyFormObj = 'joinGroup'
        this.userModifyFormModel = { 'groups': this.allGroups }
        this.joinGroupList = []
        for (let key in this.userObj.groups) {
          if (this.userObj.groups.hasOwnProperty(key)) {
            this.joinGroupList.push(this.userObj.groups[key].id)
          }
        }
        this.userModifyFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    exitGroups (gid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.joinGroupList = []
        for (let index in this.userObj.groups) {
          if (this.userObj.groups.hasOwnProperty(index)) {
            this.joinGroupList.push(this.userObj.groups[index].id)
          }
        }
        delete this.joinGroupList[this.joinGroupList.indexOf(gid)]
        this.modifyUser({ 'id': this.userObj.id, 'groups': this.joinGroupList })
      }).catch(() => {})
    },
    addRoles () {
      this.$http.get('/api/accounts/roles/').then(response => {
        this.allRoles = response.res
        this.userModifyFormTitle = '选择角色'
        this.userModifyFormObj = 'addRole'
        this.userModifyFormModel = { 'roles': this.allRoles }
        this.hasRoleList = []
        for (let key in this.userObj.roles) {
          if (this.userObj.roles.hasOwnProperty(key)) {
            this.hasRoleList.push(this.userObj.roles[key].id)
          }
        }
        this.userModifyFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removeRole (rid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.hasRoleList = []
        for (let index in this.userObj.roles) {
          if (this.userObj.roles.hasOwnProperty(index)) {
            this.hasRoleList.push(this.userObj.roles[index].id)
          }
        }
        delete this.hasRoleList[this.hasRoleList.indexOf(rid)]
        this.modifyUser({ 'id': this.userObj.id, 'roles': this.hasRoleList })
      }).catch(() => {})
    },
    addPermissions () {
      this.$http.get('/api/accounts/permissions/').then(response => {
        this.allPermissions = response.res
        this.userModifyFormTitle = '选择权限'
        this.userModifyFormObj = 'addPermission'
        this.userModifyFormModel = { 'permissions': this.allPermissions }
        this.hasPermissionList = []
        for (let key in this.userObj.permissions) {
          if (this.userObj.permissions.hasOwnProperty(key)) {
            this.hasPermissionList.push(this.userObj.permissions[key].id)
          }
        }
        this.userModifyFormVisible = true
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    removePermission (pid) {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.hasPermissionList = []
        for (let index in this.userObj.permissions) {
          if (this.userObj.permissions.hasOwnProperty(index)) {
            this.hasPermissionList.push(this.userObj.permissions[index].id)
          }
        }
        delete this.hasPermissionList[this.hasPermissionList.indexOf(pid)]
        this.modifyUser({ 'id': this.userObj.id, 'permissions': this.hasPermissionList })
      }).catch(() => {})
    },
    userModifyFromSubmit () {
      this.$refs.userModifyFrom.validate((pass) => {
        if (pass) {
          this.userModifyFormLoading = true
          if (this.userModifyFormObj === 'resetPwd') {
            this.modifyUser({ 'id': this.userObj.id, 'password': this.userModifyFormModel.password })
          } else if (this.userModifyFormObj === 'joinGroup') {
            this.modifyUser({ 'id': this.userObj.id, 'groups': this.joinGroupList })
          } else if (this.userModifyFormObj === 'addRole') {
            this.modifyUser({ 'id': this.userObj.id, 'roles': this.hasRoleList })
          } else if (this.userModifyFormObj === 'addPermission') {
            this.modifyUser({ 'id': this.userObj.id, 'permissions': this.hasPermissionList })
          }
          this.userModifyFormVisible = false
          this.userModifyFormLoading = false
        }
      })
    },
    enableOrDisable () {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.modifyUser({ 'id': this.userObj.id, 'status': !this.userObj.status })
      }).catch(() => {})
    },
    setOrMvAdmin () {
      this.$confirm('You are sure?', '提示', { type: 'warning' }).then(() => {
        this.modifyUser({ 'id': this.userObj.id, 'is_super': !this.userObj.is_super })
      }).catch(() => {})
    },
    modifyUser (data) {
      this.$http.patch('/api/accounts/users/', data).then(response => {
        this.$custom_message('success', response.res)
        this.get_users(this.userObj.name)
      }, error => {
        this.$custom_message('error', error.res)
      })
    },
    goGroupDetail (name) {
      this.$router.push({ name: 'groups_groupInfo', params: { name: name } })
    },
    goRoleDetail (name) {
      this.$router.push({ name: 'roles_roleInfo', params: { name: name } })
    }
  },
  created () {
    this.get_users(this.$route.params.name)
  },
  watch: {
    '$route': function () {
      this.get_users(this.$route.params.name)
    }
  },
  filters: {
    assertStatus: (val) => {
      if (val === true) {
        return '正常'
      } else {
        return '禁用'
      }
    },
    assertIsSuper: (val) => {
      if (val === true) {
        return '是'
      } else {
        return '否'
      }
    },
    formatDatetime: (time) => {
      let date = new Date(time)
      return dateFormat.formatDate(date, 'yyyy-MM-dd hh:mm:ss')
    }
  }
}
</script>
