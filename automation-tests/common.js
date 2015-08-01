

function sleep(time) {
  var target = UIATarget.localTarget();
  target.delay(time);
}

function test(testName, callback) {
  var target = UIATarget.localTarget();
  var app = target.frontMostApp();

  target.delay(1)

  function pass() {
    UIALogger.logPass( testName );
  }

  function fail() {
    UIALogger.logFail( testName );
  }

  function check(f) {
    if (f()){
      pass()
    }
    else {
      fail()
    }
  }

  UIALogger.logStart( testName );
  callback(target, app, check, pass)
}

function log(string) {
  UIALogger.logMessage(string)
}

function debug(string) {
  UIALogger.logDebug(string)
}

function error(string) {
  UIALogger.logError(string)
}

function warning(string) {
  UIALogger.logWarning(string)
}
