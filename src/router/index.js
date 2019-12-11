import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const originalPush = VueRouter.prototype.push
VueRouter.prototype.push = function push (location) {
  return originalPush.call(this, location).catch(err => err)
}

const routes = [
  {
    path: '/',
    name: 'dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { permission: true },
    children: [
      { path: 'accounts/users', redirect: { 'name': 'users_userList' }, meta: { permission: true } },
      { path: 'accounts/users/userList', name: 'users_userList', component: () => import('../components/accounts/users/UserList.vue'), meta: { permission: true } },
      { path: 'accounts/users/userEdit/:name', name: 'users_userEdit', component: () => import('../components/accounts/users/UserManage.vue'), meta: { permission: true } },
      { path: 'accounts/users/userInfo/:name', name: 'users_userInfo', component: () => import('../components/accounts/users/UserManage.vue'), meta: { permission: true } },
      { path: 'accounts/groups', redirect: { 'name': 'groups_groupList' }, meta: { permission: true } },
      { path: 'accounts/groups/groupList', name: 'groups_groupList', component: () => import('../components/accounts/groups/GroupList.vue'), meta: { permission: true } },
      { path: 'accounts/groups/groupEdit/:name', name: 'groups_groupEdit', component: () => import('../components/accounts/groups/GroupManage.vue'), meta: { permission: true } },
      { path: 'accounts/groups/groupInfo/:name', name: 'groups_groupInfo', component: () => import('../components/accounts/groups/GroupManage.vue'), meta: { permission: true } },
      { path: 'accounts/roles', redirect: { 'name': 'roles_roleList' }, meta: { permission: true } },
      { path: 'accounts/roles/roleList', name: 'roles_roleList', component: () => import('../components/accounts/roles/RoleList.vue'), meta: { permission: true } },
      { path: 'accounts/roles/roleEdit/:name', name: 'roles_roleEdit', component: () => import('../components/accounts/roles/RoleManage.vue'), meta: { permission: true } },
      { path: 'accounts/roles/roleInfo/:name', name: 'roles_roleInfo', component: () => import('../components/accounts/roles/RoleManage.vue'), meta: { permission: true } },
      { path: 'accounts/permissions', name: 'permissions', component: () => import('../components/accounts/permissions/Permissions.vue'), meta: { permission: true } }
    ]
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/console',
    name: 'console',
    component: () => import('../views/Console.vue')
  },
  {
    path: '/deny',
    name: 'deny',
    component: () => import('../views/Deny.vue')
  },
  {
    path: '/404',
    name: 'notFound',
    component: () => import('../views/404.vue')
  },
  {
    path: '*',
    redirect: { 'name': 'dashboard' }
  }
]

const router = new VueRouter({
  routes
})

export default router
