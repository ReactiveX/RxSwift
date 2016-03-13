

test("----- masterDetail -----", function (check, pass) {

  function yOffset (pixels) {
    return pixels / UIATarget.localTarget().frontMostApp().mainWindow().rect().size.height
  }

  var target = UIATarget.localTarget()

  target.delay(2)

  target.frontMostApp().mainWindow().tableViews()[0].cells()[10].tap();
  target.frontMostApp().navigationBar().rightButton().tap();
  target.frontMostApp().mainWindow().dragInsideWithOptions({startOffset:{x:0.93, y:yOffset(300)}, endOffset:{x:0.95, y:yOffset(200)}, duration:1.5});
  target.frontMostApp().mainWindow().dragInsideWithOptions({startOffset:{x:0.93, y:yOffset(300)}, endOffset:{x:0.95, y:yOffset(100)}, duration:1.5});

  var firstCell = UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[0]

  firstCell.tapWithOptions({tapOffset:{x:0.05, y:0.77}});

  firstCell.tapWithOptions({tapOffset:{x:0.95, y:0.77}});

  target.delay( 3 );

  target.frontMostApp().navigationBar().rightButton().tap();
  target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
  goBack();
  goBack();

  pass()
});
