
function test(testName, callback) {

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

  sleep(1)
  UIALogger.logStart( testName );
  callback(check, pass)
}

function log(string) {
  UIALogger.logMessage(string)
}

function debug(string) {
  UIALogger.logDebug(string)
}

function logElement(element) {
  UIALogger.logDebug(element.toString())
}

function error(string) {
  UIALogger.logError(string)
}

function warning(string) {
  UIALogger.logWarning(string)
}

function sleep(time) {
  UIATarget.localTarget().delay(time);
}

function writeInElement(element, text) {
  var char
  for (var i = 1; i < text.length + 1; i++) {
    element.setValue(text.substring(0, i));
  }
}


