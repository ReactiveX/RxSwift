

test("----- githubSignUp -----", function (check, pass) {

  var target = UIATarget.localTarget();

  UIATarget.onAlert = function(alert){
    var okButton = UIATarget.localTarget().frontMostApp().alert().cancelButton().tap();

     sleep(1)
     goBack()

    pass()
    return false;
  }

  target.frontMostApp().mainWindow().tableViews()[0].cells()[3].tap();

  target.frontMostApp().mainWindow().textFields()[0].tap();
  target.frontMostApp().keyboard().typeString("rxrevolution")

  target.frontMostApp().mainWindow().secureTextFields()[0].tap();
  target.frontMostApp().keyboard().typeString("mypassword")

  target.frontMostApp().mainWindow().secureTextFields()[1].tap();
  target.frontMostApp().keyboard().typeString("mypassword")

  UIATarget.localTarget().tap({x:14.50, y:80.00});
  target.frontMostApp().mainWindow().buttons()["Sign up"].tap();

  sleep(2)
});
