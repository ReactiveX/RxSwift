

test("----- githubSignUp -----", function (check, pass) {

  UIATarget.onAlert = function(alert){
    UIATarget.localTarget().frontMostApp().alert().buttons()["Cancel"].tap();
    UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

    pass()
    return false;
  }

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].tap();
  writeInElement(UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0], "rxrevolution")


  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].tap();
  writeInElement(UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0], "mypassword")


  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].tap();
  writeInElement(UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1], "mypassword")

  UIATarget.localTarget().tap({x:14.50, y:80.00});
  UIATarget.localTarget().frontMostApp().mainWindow().buttons()["Sign up"].tap();
});












