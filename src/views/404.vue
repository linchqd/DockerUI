<template>
  <div class="app-page">
    <el-card class="app-card">
      <div slot="header">
        <span>404-页面出错了!</span>
      </div>
      <div>对不起,您访问的页面丢失了,我们会尽快将它找回了!</div>
      <div><router-link to="/">&gt;&gt;&gt;返回首页</router-link></div>
    </el-card>
  </div>
</template>
<script>
export default {
  name: 'notFound'
}
</script>
