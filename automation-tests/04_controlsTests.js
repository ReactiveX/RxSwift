

UIATarget.localTarget().delay( 5 );


test("----- UIBarButtonItem tap -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  app.navigationBar().rightButton().tap();

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UIBarButtonItem Tapped";
  });

  app.navigationBar().leftButton().tap();
});



test("----- UIBarButtonItem tap -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  app.mainWindow().buttons()["TapMe"].tap();

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UIButton Tapped";
  });

  app.navigationBar().leftButton().tap();
});





test("----- UISegmentedControl tap -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  window.segmentedControls()[0].buttons()["Second"].tap();

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UISegmentedControl value 1";
  });

  window.segmentedControls()[0].buttons()["First"].tap();

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UISegmentedControl value 0";
  });

  app.navigationBar().leftButton().tap();
});




test("----- UISwitch tap -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  app.mainWindow().switches()[0].setValue(0);

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UISwitch value false";
  });

  app.mainWindow().switches()[0].setValue(1);

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UISwitch value true";
  });

  app.navigationBar().leftButton().tap();
});




test("----- UITextField text -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  app.mainWindow().textFields()[0].textFields()[0].tap();
  app.keyboard().typeString("t");

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UITextField text t";
  });

  app.navigationBar().leftButton().tap();
});





test("----- UISlider value -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  app.mainWindow().sliders()[0].dragToValue(0.00);

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UISlider value 0.0";
  });

  app.navigationBar().leftButton().tap();
});




test("----- UIDatePicker date -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  app.mainWindow().pickers()[0].wheels()[0].tapWithOptions({tapOffset:{x:0.49, y:0.65}});
  app.mainWindow().pickers()[0].wheels()[1].tapWithOptions({tapOffset:{x:0.35, y:0.64}});
  app.mainWindow().pickers()[0].wheels()[2].tapWithOptions({tapOffset:{x:0.46, y:0.64}});

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UIDatePicker date 1970-01-02 00:00:00 +0000";
  });

  app.navigationBar().leftButton().tap();
});




test("----- UIActionSheet tap -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  window.buttons()["Open ActionSheet"].tap();
  app.actionSheet().collectionViews()[0].cells()["OK"].buttons()["OK"].tap();

  target.delay( 2 );

  check(function () {
    var textValue = window.staticTexts()["debugLabel"].value();
    return textValue === "UIActionSheet didDismissWithButtonIndex 0";
  });

  app.navigationBar().leftButton().tap();
});


test("----- UIAlertView tap -----", function (target, app, check) {
  var window = app.mainWindow();

  window.tableViews()[0].tapWithOptions({tapOffset:{x:0.31, y:0.38}});

  UIATarget.onAlert = function(alert){
    UIATarget.onAlert = null
    app.alert().buttons()["Three"].tap();
    target.delay( 2 );

    check(function () {
      var textValue = window.staticTexts()["debugLabel"].value();
      return textValue === "UIAlertView didDismissWithButtonIndex 3";
    });

    UIATarget.onAlert = function () {
      return false;
    };

    app.navigationBar().leftButton().tap();
    return false;
  }

  window.buttons()["Open AlertView"].tap();
  target.delay( 4 );
});












