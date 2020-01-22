let menus = [
  { url: '/', name: 'dashboard', text: 'Dashboard', icon: 'tachometer-alt', active: false, is_expanded: false, permission: '系统默认角色' },
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
  },
  {
    text: '资产管理',
    icon: 'hand-holding-usd',
    active: false,
    is_expanded: false,
    permission: 'assets',
    secMenu: [
      { url: '/assets/servers/serverList', name: 'servers', text: '服务器管理', icon: 'server', active: false, permission: '' }
    ]
  },
  {
    text: 'Wiki管理',
    icon: 'folder',
    active: false,
    is_expanded: false,
    permission: 'Wiki管理员',
    secMenu: [
      { url: '/wiki/docs/', name: 'docs', text: '文档列表', icon: 'file-code', active: false, is_expanded: false, permission: '' },
      { url: '/wiki/kinds/', name: 'kinds', text: '分类列表', icon: 'file', active: false, is_expanded: false, permission: '' }
    ]
  },
  {
    text: '配置中心',
    icon: 'cog',
    active: false,
    is_expanded: false,
    permission: '配置管理员',
    secMenu: [
      { url: '/configs/env/', name: 'env', text: '环境管理', icon: 'th-large', active: false, is_expanded: false, permission: '' },
      { url: '/configs/conf/', name: 'conf', text: '配置管理', icon: 'file-code', active: false, is_expanded: false, permission: '' }
    ]
  }
]
export default menus
