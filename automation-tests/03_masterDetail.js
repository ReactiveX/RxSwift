

test("----- masterDetail -----", function (target, app, check, pass) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.41, y:0.32}});
  app.navigationBar().rightButton().tap();
  window.tableViews()[0].dragInsideWithOptions({startOffset:{x:0.93, y:0.58}, endOffset:{x:0.95, y:0.28}, duration:1.5});
  window.tableViews()[0].dragInsideWithOptions({startOffset:{x:0.94, y:0.58}, endOffset:{x:0.92, y:0.18}, duration:1.5});
  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.07, y:0.35}});
  window.tableViews()[0].cells()[2].tapWithOptions({tapOffset:{x:0.93, y:0.64}});
  app.navigationBar().rightButton().tap();
  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.30, y:0.23}});
  app.navigationBar().leftButton().tap();
  app.navigationBar().leftButton().tap();

  pass()
});












