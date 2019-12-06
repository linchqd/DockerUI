const SERVER = require('./src/config/server.config')
module.exports = {
  devServer: {
    host: SERVER.host,
    port: SERVER.port,
    proxy: {
      '/api/': {
        target: SERVER.api_server_url,
        ws: true,
        changeOrigin: true,
        pathRewrite: {
          '^/api': ''
        }
      }
    }
  }
}
