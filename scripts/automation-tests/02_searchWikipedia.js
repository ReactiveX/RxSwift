

test("----- searchWikipedia -----", function (check, pass) {

  var target = UIATarget.localTarget()

  var width = target.frontMostApp().mainWindow().rect().size.width

  target.frontMostApp().mainWindow().tableViews()[0].cells()[12].tap();

  target.delay(2);

  var searchBar = target.frontMostApp().mainWindow().searchBars()[0];

  searchBar.tap()
  target.frontMostApp().keyboard().typeString("banana");

  target.delay(1);

  target.tap({x:width - 40, y:43});

  target.delay(1);

  searchBar.tap();
  target.delay(1);

  target.frontMostApp().keyboard().typeString("Yosemite");
  target.delay(1);

  target.tap({x:width - 40, y:43});

  goBack();

  pass();
});
