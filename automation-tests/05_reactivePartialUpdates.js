

test("----- reactivePartialUpdates -----", function (target, app, check, pass) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.49, y:0.70}});
  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.36, y:0.56}});
  app.navigationBar().rightButton().tap();
  app.navigationBar().rightButton().tap();
  app.navigationBar().rightButton().tap();
  app.navigationBar().rightButton().tap();
  app.navigationBar().rightButton().tap();
  app.navigationBar().rightButton().tap();
  app.navigationBar().rightButton().tap();
  app.navigationBar().leftButton().tap();

  pass()
});












