<template>
  <div class="app" :class="{'mini': mini}">
    <header class="app-header">
      <a class="app-header__logo" href="/">Docker管理平台</a>
      <a @click="ToMini" class="app-header_toggle"><font-awesome-icon icon="align-justify" size="lg"/></a>
      <span style="flex: 1 1 auto;"></span>
      <div class="app-header_userProfile">
        <el-dropdown trigger="click" @command="handleCommand">
          <span class="el-dropdown-link ">
            <font-awesome-icon icon="user" fixed /> {{ $store.getters['loginModule/getUserInfo'].nickname }} <i class="el-icon-arrow-down el-icon--right"></i>
          </span>
          <el-dropdown-menu slot="dropdown">
              <el-dropdown-item command="logout">
                <span>退出登录</span><font-awesome-icon icon="sign-out-alt" fixed />
              </el-dropdown-item>
          </el-dropdown-menu>
        </el-dropdown>
      </div>
    </header>
    <aside class="app-aside">
      <Aside />
    </aside>
    <main class="app-main">
      <Main />
    </main>
  </div>
</template>

<script>
import Aside from '../components/Aside.vue'
import Main from '../components/Main.vue'

export default {
  name: 'dashboard',
  data () {
    return {
      mini: false
    }
  },
  components: {
    Aside, Main
  },
  methods: {
    ToMini () { // 小图标展示
      this.mini = !this.mini
    },
    handleCommand (command) {
      if (command === 'logout') {
        this.$store.dispatch('loginModule/setLoginStatus', false)
        localStorage.removeItem('token')
        this.$router.push({ name: 'login', query: { redirect: this.$route.fullPath } })
      }
    }
  },
  mounted () {
    window.onresize = () => {
      this.mini = document.body.clientWidth <= 1024
    }
  }
}
</script>
