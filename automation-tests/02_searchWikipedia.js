

test("----- searchWikipedia -----", function (check, pass) {

  var width = UIATarget.localTarget().frontMostApp().mainWindow().rect().size.width

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("banana"); // fails if software keyboard is disabled
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("b");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("ba");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("ban");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("bana");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("banan");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("banana");
  UIATarget.localTarget().delay(2);

  UIATarget.localTarget().tap({x:width - 40, y:43});

  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("Yosemite"); // fails if software keyboard is disabled
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Y");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yo");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yos");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yose");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yosem");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yosemi");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yosemit");
  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].setValue("Yosemite");
  UIATarget.localTarget().delay(2);


  UIATarget.localTarget().tap({x:width - 40, y:43});
  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

  pass()
});












