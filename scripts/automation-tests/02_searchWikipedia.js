

test("----- searchWikipedia -----", function (check, pass) {

  var width = UIATarget.localTarget().frontMostApp().mainWindow().rect().size.width

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[3].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].tap();
  writeInElement(UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0], "banana")
  UIATarget.localTarget().delay(2);

  UIATarget.localTarget().tap({x:width - 40, y:43});

  UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0].tap();
  writeInElement(UIATarget.localTarget().frontMostApp().mainWindow().searchBars()[0].searchBars()[0], "Yosemite")
  UIATarget.localTarget().delay(2);


  UIATarget.localTarget().tap({x:width - 40, y:43});
  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

  pass()
});












