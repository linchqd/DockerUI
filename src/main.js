import Vue from 'vue'
import App from './App.vue'
import store from './store/index.js'
import router from './router'
import ElementUI from 'element-ui'
import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import 'element-ui/lib/theme-chalk/index.css'
import httpTools from './request.js'
import './assets/css/app.css'

library.add(fas)
Vue.component('font-awesome-icon', FontAwesomeIcon)
Vue.use(ElementUI)
httpTools.install(Vue, router)

Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
