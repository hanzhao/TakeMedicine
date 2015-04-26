app = require 'app'
BrowserWindow = require 'browser-window'

mainWindow = null

app.on 'window-all-closed', ->
  app.exit() unless process.platform is 'darwin'

app.on 'ready', ->
  mainWindow = new BrowserWindow
    height: 700
    width: 500
  # mainWindow.openDevTools
  #   detach: true
  mainWindow.loadUrl "http://localhost:3000/doctor/signin"
  mainWindow.on 'closed', ->
    mainWindow = null
