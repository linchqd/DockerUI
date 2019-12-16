<template>
  <div id="terminal"></div>
</template>
<script>
import 'xterm/css/xterm.css'
import { Terminal } from 'xterm'
import { FitAddon } from 'xterm-addon-fit'
import { AttachAddon } from 'xterm-addon-attach'

export default {
  data () {
    return {
      data: {
        token: '',
        host: '',
        xterm_width: 0,
        xterm_height: 0
      },
      terminal: null,
      webSocket: null
    }
  },
  methods: {
    socketConnected (event) {
      this.webSocket.send(JSON.stringify(this.data))
    },
    socketClosed (event) {
      this.terminal.write('\n\r\x1B[1;3;31msocket is already closed.\x1B[0m')
    },
    socketError (event) {
      console.log('Error: ' + event)
    }
  },
  mounted () {
    this.data.token = this.$store.getters['loginModule/getUserInfo'].token
    if (this.$route.query.hasOwnProperty('server')) {
      this.data.host = this.$route.query.server
    }
    this.data.xterm_width = Math.floor(window.innerWidth / 9)
    this.data.xterm_height = Math.floor(window.innerHeight / 18)
    this.terminal = new Terminal({
      cols: this.data.xterm_width,
      rows: this.data.xterm_height,
      cursorBlink: true,
      cursorStyle: 'underline',
      scrollback: 800,
      tabStopWidth: 8,
      screenKeys: true
    })
    const fitAddon = new FitAddon()
    this.terminal.loadAddon(fitAddon)
    this.terminal.open(document.getElementById('terminal'), true)
    fitAddon.fit()
    this.webSocket = new WebSocket('ws://' + window.location.host + '/api/ws/webTerminal/')
    this.webSocket.onopen = this.socketConnected
    this.webSocket.onclose = this.socketClosed
    this.webSocket.onerror = this.socketError
    this.terminal.loadAddon(new AttachAddon(this.webSocket))
    this.terminal._initialized = true
    this.terminal.onSelectionChange(() => {
      if (this.terminal.hasSelection()) {
        document.execCommand('Copy')
        this.$custom_message('success', 'copy success', 1000)
      }
    })
  },
  beforeDestroy () {
    this.webSocket.close()
    this.terminal.dispose()
  }
}
</script>
