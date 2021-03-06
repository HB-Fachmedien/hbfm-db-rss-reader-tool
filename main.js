'use strict';
const electron = require('electron')
// Module to control application life.
const app = electron.app
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow

const path = require('path')
const url = require('url')
const ipc = electron.ipcMain;

const log = require('electron-log');
log.transports.file.maxSize = 2 * 1024 * 1024;
 
// Write to this file, must be set before first logging 
log.transports.file.file = './log.txt';
 
// fs.createWriteStream options, must be set before first logging 
log.transports.file.streamConfig = { flags: 'w' };



// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 850, height: 850, icon: 'favicon_hbfm.ico'})

  // and load the index.html of the app.
  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  }))

  // Open the DevTools.
  //mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    log.warn("Logging beendet.")
    mainWindow = null
  })

  // Identify System Proxy
  ipc.on('proxy-request', (event, arg) => {
    console.log("proxy-request empfangen");
    const ses = mainWindow.webContents.session;
    ses.resolveProxy("https://www.der-betrieb.de", function(proxy){
      // die resolveProxy Funktion gibt einen String in der Form PROXY <<proxyURL>> zurück:
      // der String wird dann passend gekürzt:
      let pattern = /PROXY\s/g;
      proxy = proxy.replace(pattern,'');
      console.log("URL resolved: ", proxy);
      log.warn("URL resolved: ", proxy);
      event.sender.send('proxy-response', proxy);
    })
    
  });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})

process.on('uncaughtException', (err) => {
  log.error('Uncaught Exception:');
  log.error(err);
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.