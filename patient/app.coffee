app = require 'app'
BrowserWindow = require 'browser-window'

mainWindow = null

app.on 'window-all-closed', ->
  app.exit() unless process.platform is 'darwin'

app.on 'ready', ->
  mainWindow = new BrowserWindow
    height: 600
    width: 400
  # mainWindow.openDevTools
  #   detach: true
  mainWindow.loadUrl "http://localhost:3000/patient/signin"
  mainWindow.on 'closed', ->
    mainWindow = null
