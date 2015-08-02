

test("----- githubSignUp -----", function (check, pass) {

  UIATarget.onAlert = function(alert){
    UIATarget.localTarget().frontMostApp().alert().buttons()["Cancel"].tap();
    UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

    pass()
    return false;
  }

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[0].tapWithOptions({tapOffset:{x:0.24, y:0.20}});

  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("rxrevolution"); // fails if software keyboard is disabled
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("r");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rx");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxr");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxre");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrev");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevo");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevol");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevolu");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevolut");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevoluti");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevolutio");
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("rxrevolution");


  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("mypassword"); // fails if software keyboard is disabled
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("m");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("my");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("myp");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypa");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypas");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypass");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypassw");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypasswo");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypasswor");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[0].setValue("mypassword");


  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("mypassword"); // fails if software keyboard is disabled
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("m");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("my");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("myp");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypa");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypas");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypass");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypassw");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypasswo");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypasswor");
  UIATarget.localTarget().frontMostApp().mainWindow().secureTextFields()[1].setValue("mypassword");

  UIATarget.localTarget().tap({x:14.50, y:80.00});
  UIATarget.localTarget().frontMostApp().mainWindow().buttons()["Sign up"].tap();
});












