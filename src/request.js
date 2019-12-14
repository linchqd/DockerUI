import axios from 'axios'
import SERVER from './config/server.config'
import store from './store'

let httpTools = {
  install: null
}
// 处理response并返回结果
function parseResponse (response, router) {
  if (response.status === 401) {
    router.push({ name: 'login' })
    response['res'] = response.data.message
  } else if (response.status === 403) {
    router.push({ name: 'deny' })
    response['res'] = response.data.message
  } else if (response.status === 404) {
    router.push({ name: 'notFound' })
    response['res'] = response.data.message
  } else if (response.data.hasOwnProperty('message')) {
    response['res'] = response.data.message
  } else if (response.data.hasOwnProperty('data')) {
    response['res'] = response.data.data
    return Promise.resolve(response)
  } else {
    response['res'] = '未知错误'
  }
  return Promise.reject(response)
}

function deepCopy (obj) {
  let result = Array.isArray(obj) ? [] : {}
  for (let key in obj) {
    if (obj.hasOwnProperty(key)) {
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        result[key] = deepCopy(obj[key])
      } else {
        result[key] = obj[key]
      }
    }
  }
  return result
}

function compare (property) {
  return function (a, b) {
    let value1 = a[property]
    let value2 = b[property]
    return value1 - value2
  }
}

function sortArr (Arr, property) {
  return Arr.sort(compare(property))
}

function isIncludes (Arr, subArr) {
  for (let item of subArr) {
    if (!Arr.includes(item.trim())) {
      return false
    }
  }
  return true
}

// assert login in
function loggedIn () {
  let token = ''
  if (store.getters['loginModule/getLoginStatus']) {
    token = store.getters['loginModule/getUserInfo'].token
    return true
  } else {
    token = localStorage.getItem('token')
    if (token && token.length === 32) {
      let userInfo = {}
      let arr = ['token', 'is_super', 'roles', 'nickname', 'username']
      for (let key in arr) {
        if (arr[key] === 'is_super') {
          userInfo[arr[key]] = localStorage.getItem(arr[key]) === 'true'
          continue
        }
        userInfo[arr[key]] = localStorage.getItem(arr[key])
      }
      userInfo.roles = userInfo.roles !== null ? userInfo.roles.split(',') : []
      store.dispatch('loginModule/setLoginStatus', true)
      store.dispatch('loginModule/setUserInfo', userInfo)
      return true
    }
  }
  return false
}

httpTools.install = function (Vue, router) {
  // 请求前加token
  axios.interceptors.request.use(request => {
    request.headers['X-TOKEN'] = store.getters['loginModule/getUserInfo'].token
    request.timeout = SERVER.TIMEOUT
    return request
  })
  // 返回结果处理
  axios.interceptors.response.use(response => {
    return parseResponse(response, router)
  }, error => {
    return parseResponse(error.response, router)
  })
  Vue.prototype.$http = axios
  Vue.prototype.$deepCopy = deepCopy
  Vue.prototype.$sortArr = sortArr
  Vue.prototype.$custom_message = function (type, message, time = 5000) {
    this.$message({
      showClose: true,
      duration: time,
      message: message,
      type: type
    })
  }
  Vue.prototype.$assert_permission = function (permission) {
    if (store.getters['loginModule/getUserInfo'].is_super === 'true') {
      return true
    }
    let roles = store.getters['loginModule/getUserInfo'].roles
    if (!roles || !permission) {
      return false
    }
    for (let item of permission.split('|')) {
      if (isIncludes(roles, item.split('&'))) {
        return true
      }
    }
    return false
  }
  router.beforeEach((to, from, next) => {
    if (['/login', '/deny', '/404'].includes(to.path)) {
      next()
    } else if (to.matched.some(record => record.meta.permission)) {
      if (!loggedIn()) {
        next({
          name: 'login',
          query: { redirect: to.fullPath }
        })
      } else {
        next()
      }
    } else {
      next() // 确保一定要调用 next()
    }
  })
}
export default httpTools
