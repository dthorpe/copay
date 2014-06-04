'use strict';

var config = defaultConfig;
var localConfig = JSON.parse(localStorage.getItem('config'));

if (localConfig) {
  var count = 0;
  for (name in localConfig) {
    if (localConfig.hasOwnProperty(name)) {
      config[name] = localConfig[name];
    }
  }
}

var log = function() {
  if (config.verbose) console.log(arguments);
}

// From the bundle
var copay = require('copay');

var copayApp = window.copayApp = angular.module('copayApp',[
  'ngRoute',
  'angularMoment',
  'mm.foundation',
  'monospaced.qrcode',
  'notifications',
  'copayApp.filters',
  'copayApp.controllers',
  'copayApp.directives',
  'copayApp.services',
]);

angular.module('copayApp.filters', []);
angular.module('copayApp.controllers', []);
angular.module('copayApp.directives', []);
angular.module('copayApp.services', []);

