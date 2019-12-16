let validator = {
  ip: function (rule, value, callback) {
    const REGEX = /^(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|[1-9])\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)$/
    if (value === '') {
      return callback(new Error('ip地址不能为空'))
    }
    if (!REGEX.test(value)) {
      callback(new Error('请输入正确的ip地址'))
    } else {
      callback()
    }
  },
  digits: function (rule, value, callback) {
    const REGEX = /^\d+$/
    if (value === '') {
      return callback(new Error('字段不能为空'))
    }
    if (!REGEX.test(value)) {
      callback(new Error('请输入正确的数字'))
    } else {
      callback()
    }
  }
}
export default validator
