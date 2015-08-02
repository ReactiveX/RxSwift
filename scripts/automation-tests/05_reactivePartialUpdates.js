

test("----- reactivePartialUpdates -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tapWithOptions({tapOffset:{x:0.24, y:0.20}});
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












