<template>
    <ul class="app-menu">
      <template v-for="(menu, index) in menus">
        <li v-if="$assert_permission(menu.permission) || $store.getters['loginModule/getUserInfo'].is_super" :key="index" @click="showToggle(menu)" :class="[{'miniActive': menu.active}, {'active': menu.active && !menu.is_expanded}, {'treeview': menu.secMenu}, {'is-expanded': menu.is_expanded}]">
          <router-link v-if="!menu.secMenu" :class="['app-menu__item', {'active': menu.active} ]" :to="menu.url">
            <font-awesome-icon :icon="menu.icon" size="lg" fixed-width />
            <span class="app-menu__label">{{ menu.text }}</span>
          </router-link>
          <a v-else class="app-menu__item" data-toggle="treeview">
            <font-awesome-icon :icon="menu.icon" size="lg" fixed-width />
            <span class="app-menu__label">{{ menu.text }}</span>
            <font-awesome-icon icon="angle-right" fixed-width :class="{'fa-rotate-90': menu.is_expanded}" />
          </a>
          <ul v-if="menu.secMenu" class="treeview-menu">
            <template v-for="(secMenu, index) in menu.secMenu">
              <li v-if="$store.getters['loginModule/getUserInfo'].is_super || $assert_permission(secMenu.permission)" @click.stop="showToggle(menu, secMenu)" :key="index">
                <router-link :class="['treeview-item', {'active': secMenu.active}]" :to="secMenu.url">
                  <font-awesome-icon :icon="secMenu.icon" size="sm" fixed-width />{{ secMenu.text }}
                </router-link>
              </li>
            </template>
          </ul>
      </li>
      </template>
    </ul>
</template>

<script>
import asideMenu from '../config/config.js'
export default {
  name: 'Aside',
  data () {
    return {
      menus: asideMenu,
      temp: {}
    }
  },
  methods: {
    showToggle (menu, secMenu) { // 展开二级菜单
      if (secMenu) {
        // 如果点击的是二级菜单, 设置其active为true, 其他的菜单active为false, 设置其父菜单is_expanded保持为true
        secMenu.active = true
        menu.is_expanded = true
        menu.active = true
        this.menus.forEach(function (item) {
          if (!(item === menu)) {
            item.active = false
          }
          if (item.secMenu) {
            item.secMenu.forEach(function (secitem) {
              if (!(secitem === secMenu)) {
                secitem.active = false
              }
            })
          }
        })
      } else {
        // 如果点击的一级菜单有二级菜单,设置其is_expanded取反, 其他的is_expanded为false
        if (menu.secMenu) {
          menu.is_expanded = !menu.is_expanded
          this.menus.forEach(function (item) {
            if (!(item === menu)) {
              item.is_expanded = false
            }
          })
        } else {
          // 如果点击的是一级菜单并且该一级菜单没有二级菜单时设置其active为true,其他所有菜单的active为false,is_expanded为false
          menu.active = true
          this.menus.forEach(function (item) {
            if (!(item === menu)) {
              item.is_expanded = false
              item.active = false
              if (item.secMenu) {
                item.secMenu.forEach(function (secitem) {
                  secitem.active = false
                })
              }
            }
          })
        }
      }
    },
    initToggle (rname) {
      this.menus.forEach((item) => {
        if (rname.startsWith(item.name)) {
          item.active = true
          this.temp = item
        } else {
          if (item.secMenu) {
            if (Object.keys(this.temp).length > 0) {
              item.secMenu.forEach(function (secitem) {
                secitem.active = false
              })
              item.active = false
              item.is_expanded = false
            } else {
              item.secMenu.forEach((secitem) => {
                if (rname.startsWith(secitem.name)) {
                  secitem.active = true
                  item.is_expanded = true
                  item.active = true
                  this.temp = item
                } else {
                  secitem.active = false
                  if (this.temp !== item) {
                    item.is_expanded = false
                    item.status = false
                  }
                }
              })
            }
          } else {
            item.status = false
          }
        }
      })
    }
  },
  created () {
    this.initToggle(this.$route.name)
  }
}
</script>
