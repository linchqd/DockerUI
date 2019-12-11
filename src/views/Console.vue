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
      copy: ''
    }
  },
  mounted () {
    let terminalContainer = document.getElementById('terminal')
    let terminal = new Terminal({
      cursorBlink: true
    })
    const fitAddon = new FitAddon()
    terminal.loadAddon(fitAddon)
    terminal.open(terminalContainer, true)
    terminal.write('Hello from \x1B[1;3;31mxterm.js\x1B[0m $ ')
    fitAddon.fit()

    let webSocket = new WebSocket('ws:**********')
    webSocket.binaryType = 'arraybuffer'
    webSocket.onopen = function (evt) {
      console.log('onopen', evt)
      terminal.writeln(
        '******************************************************************'
      )
    }
    const attachAddon = new AttachAddon(webSocket)
    terminal.loadAddon(attachAddon)
  }
}
</script>
