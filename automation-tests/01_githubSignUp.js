

test("----- githubSignUp -----", function (target, app, check, pass) {
  var window = app.mainWindow();

  UIATarget.onAlert = function(alert){
    app.alert().buttons()["Cancel"].tap();
    app.navigationBar().leftButton().tap();
    return false;
  }

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.24, y:0.20}});
  window.textFields()[0].textFields()[0].tap();app.keyboard().typeString("rxrevolution");
  window.secureTextFields()[0].secureTextFields()[0].tap();
  app.keyboard().typeString("mypassword");
  window.secureTextFields()[1].secureTextFields()[0].tap();
  app.keyboard().typeString("mypassword");
  window.buttons()["Sign up"].tap();
  app.navigationBar().leftButton().tap();

  pass()
});












