

test("----- githubSignUp -----", function (check, pass) {

  var target = UIATarget.localTarget();

  UIATarget.onAlert = function(alert){
    var okButton = UIATarget.localTarget().frontMostApp().alert().buttons()["OK"];
    okButton.tap();

    UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

    pass()
    return false;
  }

  target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();

  target.frontMostApp().mainWindow().textFields()[0].tap();
  writeInElement(target.frontMostApp().mainWindow().textFields()[0], "rxrevolution")


  target.frontMostApp().mainWindow().secureTextFields()[0].tap();
  writeInElement(target.frontMostApp().mainWindow().secureTextFields()[0], "mypassword")


  target.frontMostApp().mainWindow().secureTextFields()[1].tap();
  writeInElement(target.frontMostApp().mainWindow().secureTextFields()[1], "mypassword")

  UIATarget.localTarget().tap({x:14.50, y:80.00});
  target.frontMostApp().mainWindow().buttons()["Sign up"].tap();
});
