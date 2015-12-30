

test("----- masterDetail -----", function (check, pass) {

  function yOffset (pixels) {
    return pixels / UIATarget.localTarget().frontMostApp().mainWindow().rect().size.height
  }

  var target = UIATarget.localTarget()

  target.frontMostApp().mainWindow().tableViews()[0].cells()[8].tap();
  target.frontMostApp().navigationBar().rightButton().tap();
  target.frontMostApp().mainWindow().dragInsideWithOptions({startOffset:{x:0.93, y:yOffset(300)}, endOffset:{x:0.95, y:yOffset(200)}, duration:1.5});
  target.frontMostApp().mainWindow().dragInsideWithOptions({startOffset:{x:0.93, y:yOffset(300)}, endOffset:{x:0.95, y:yOffset(100)}, duration:1.5});

  var firstCell = UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[1]

  firstCell.buttons()[0].tap();

  firstCell.buttons()["Delete"].tap();

  target.delay( 3 );

  target.frontMostApp().navigationBar().rightButton().tap();
  target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
  target.frontMostApp().navigationBar().leftButton().tap();
  target.frontMostApp().navigationBar().leftButton().tap();

  pass()
});
