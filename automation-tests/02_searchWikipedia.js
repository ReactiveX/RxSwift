

test("----- searchWikipedia -----", function (target, app, check, pass) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.22, y:0.26}});
  window.searchBars()[0].searchBars()[0].tap();
  app.keyboard().typeString("functional");
  target.tap({x:325.00, y:42.33});
  app.keyboard().typeString("Yosemite");
  target.tap({x:375.33, y:43.33});
  app.navigationBar().leftButton().tap();

  pass()
});












