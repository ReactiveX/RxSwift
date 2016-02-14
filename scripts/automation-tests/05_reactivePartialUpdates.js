

test("----- reactivePartialUpdates -----", function (check, pass) {
  var target = UIATarget.localTarget()

  target.frontMostApp().mainWindow().tableViews()[0].cells()[11].tap();

  var rightButton = target.frontMostApp().navigationBar().rightButton();
  rightButton.tap();
  rightButton.tap();
  rightButton.tap();
  rightButton.tap();
  rightButton.tap();
  rightButton.tap();
  rightButton.tap();

  goBack()

  pass()
});
