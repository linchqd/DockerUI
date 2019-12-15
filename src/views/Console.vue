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
      data: { 'token': '123456', 'connect_info': { 'host': '192.168.10.20' } },
      copy: '',
      terminal: null,
      webSocket: null,
      cols: 0,
      rows: 0
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
    this.cols = Math.floor(window.innerWidth / 9)
    this.rows = Math.floor(window.innerHeight / 17)
    this.data.connect_info['xterm_width'] = this.cols
    this.data.connect_info['xterm_height'] = this.rows
    this.terminal = new Terminal({
      cols: this.cols,
      rows: this.rows,
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
