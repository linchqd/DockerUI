<template>
  <div id="terminal"></div>
</template>
<script>
import 'xterm/css/xterm.css'
import { Terminal } from 'xterm'
// import { FitAddon } from 'xterm-addon-fit'
import { AttachAddon } from 'xterm-addon-attach'

export default {
  data () {
    return {
      data: { 'token': '123456' },
      copy: '',
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
    },
    socketMessage (event) {
      this.terminal.write(event.data)
    }
  },
  mounted () {
    this.terminal = new Terminal({
      cols: 92,
      rows: 22,
      cursorBlink: true,
      cursorStyle: 'underline',
      scrollback: 800,
      tabStopWidth: 8,
      screenKeys: true
    })
    // const fitAddon = new FitAddon()
    // this.terminal.loadAddon(fitAddon)
    this.terminal.open(document.getElementById('terminal'), true)
    this.webSocket = new WebSocket('ws://127.0.0.1:8000/webshell')
    this.webSocket.onopen = this.socketConnected
    this.webSocket.onclose = this.socketClosed
    this.webSocket.onerror = this.socketError
    this.webSocket.onmessage = this.socketMessage
    this.terminal.loadAddon(new AttachAddon(this.webSocket))
    // fitAddon.fit()
  }
}
</script>
