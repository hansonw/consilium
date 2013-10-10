var exec = require("cordova/exec");
module.exports = {
  get: function (message, win, fail) {
    exec(win, fail, "Downloader", "get", [message]);
  }
};
