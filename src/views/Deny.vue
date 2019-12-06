<template>
  <div class="app-page">
    <el-card class="app-card">
      <div slot="header">
        <span>403-访问拒绝!</span>
      </div>
      <div>对不起,您没有权限访问该页面!</div>
      <div>
        <a @click="$router.push({name: 'login'})">&lt;&lt;&lt;重新登陆</a>
        <a @click="$router.push({name: 'dashboard'})">返回首页&gt;&gt;&gt;</a>
      </div>
    </el-card>
  </div>
</template>
<script>
export default {
  name: 'deny'
}
</script>
