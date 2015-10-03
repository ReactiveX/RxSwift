

test("----- masterDetail -----", function (check, pass) {

  function yOffset (pixels) {
    return pixels / UIATarget.localTarget().frontMostApp().mainWindow().rect().size.height
  }


  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().mainWindow().dragInsideWithOptions({startOffset:{x:0.93, y:yOffset(300)}, endOffset:{x:0.95, y:yOffset(200)}, duration:1.5});
  UIATarget.localTarget().frontMostApp().mainWindow().dragInsideWithOptions({startOffset:{x:0.93, y:yOffset(300)}, endOffset:{x:0.95, y:yOffset(100)}, duration:1.5});

  var firstCell = UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[1]

  firstCell.buttons()[0].tap();

  firstCell.buttons()["Delete"].tap();

  UIATarget.localTarget().delay( 2 );

  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();
  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();

  pass()
});
