let menus = [{
  url: '/',
  name: 'dashboard',
  text: 'Dashboard',
  icon: 'tachometer-alt',
  active: false,
  is_expanded: false,
  permission: '系统默认角色'
},
{
  text: '账户管理',
  icon: 'user-plus',
  active: false,
  is_expanded: false,
  permission: '账户管理员',
  secMenu: [
    { url: '/accounts/users/userList', permission: '账户管理员', name: 'users', text: '用户管理', icon: 'user', active: false },
    { url: '/accounts/groups/groupList', permission: '账户管理员', name: 'groups', text: '用户组管理', icon: 'users', active: false },
    { url: '/accounts/roles/roleList', permission: '', name: 'roles', text: '角色管理', icon: 'user-secret', active: false },
    { url: '/accounts/permissions', permission: '', name: 'permissions', text: '权限管理', icon: 'user-lock', active: false }
  ]
}]
export default menus
