

test("----- reactivePartialUpdates -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[5].tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

  pass()
});












