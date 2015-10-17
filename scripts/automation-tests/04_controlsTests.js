

test("----- UIAlertView tap -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.onAlert = function(alert){
    UIATarget.localTarget().onAlert = null
    UIATarget.localTarget().frontMostApp().alert().buttons()["Three"].tap();
    UIATarget.localTarget().delay( 1 );

    check(function () {
      var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
      return textValue === "UIAlertView didDismissWithButtonIndex 3";
    });

    UIATarget.onAlert = function () {
      return false;
    };

    UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
    return false;
  }

  UIATarget.localTarget().frontMostApp().mainWindow().buttons()["Open AlertView"].tap();
  UIATarget.localTarget().delay( 4 );
});

test("----- UIBarButtonItem tap -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIBarButtonItem Tapped";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});



test("----- UIBarButtonItem tap -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().buttons()["TapMe"].tap();

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIButton Tapped";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});





test("----- UISegmentedControl tap -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().segmentedControls()[0].buttons()["Second"].tap();

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISegmentedControl value 1";
  });

  UIATarget.localTarget().frontMostApp().mainWindow().segmentedControls()[0].buttons()["First"].tap();

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISegmentedControl value 0";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});




test("----- UISwitch tap -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().switches()[0].setValue(0);

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISwitch value false";
  });

  UIATarget.localTarget().frontMostApp().mainWindow().switches()[0].setValue(1);

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISwitch value true";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});




test("----- UITextField text -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("t");// fails if software keyboard is disabled
  UIATarget.localTarget().frontMostApp().mainWindow().textFields()[0].setValue("t");

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UITextField text t";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});





test("----- UISlider value -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().sliders()[0].dragToValue(0.00);

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISlider value 0.0";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});




test("----- UIDatePicker date -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().pickers()[0].wheels()[0].tapWithOptions({tapOffset:{x:0.49, y:0.65}});
  UIATarget.localTarget().frontMostApp().mainWindow().pickers()[0].wheels()[1].tapWithOptions({tapOffset:{x:0.35, y:0.64}});
  UIATarget.localTarget().frontMostApp().mainWindow().pickers()[0].wheels()[2].tapWithOptions({tapOffset:{x:0.46, y:0.64}});

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIDatePicker date 1970-01-02 00:00:00 +0000";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});




test("----- UIActionSheet tap -----", function (check, pass) {

  UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[4].tap();

  UIATarget.localTarget().frontMostApp().mainWindow().buttons()["Open ActionSheet"].tap();
  UIATarget.localTarget().frontMostApp().actionSheet().collectionViews()[0].cells()["OK"].buttons()["OK"].tap();

  UIATarget.localTarget().delay( 2 );

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIActionSheet didDismissWithButtonIndex 0";
  });

  UIATarget.localTarget().frontMostApp().navigationBar().leftButton().tap();
});
