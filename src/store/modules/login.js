const state = {
  isLogin: false,
  userInfo: {}
}
const getters = {
  getLoginStatus: (state, getters, rootState) => {
    return state.isLogin
  },
  getUserInfo: (state, getters, rootState) => {
    return state.userInfo
  }
}
const actions = {
  setLoginStatus (context, status) {
    context.commit('setLoginStatus', status)
  },
  setUserInfo (context, userInfo) {
    context.commit('setUserInfo', userInfo)
  }
}
const mutations = {
  setLoginStatus (state, status) {
    state.isLogin = status
  },
  setUserInfo (state, userInfo) {
    state.userInfo = userInfo
  }
}
export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
