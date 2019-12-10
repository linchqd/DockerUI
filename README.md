# vue-projects

## Project setup
```
git clone -b web https://github.com/linchqd/DockerUI.git web
cd web
npm config set registry http://registry.npm.taobao.org/
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
docker build --rm -t app:v1 .
docker run --name app -d -p 80:80 app:v1
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
