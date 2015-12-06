
var target = UIATarget.localTarget()

var apiTestIndex = 3

test("----- UIAlertView tap -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  UIATarget.onAlert = function(alert){
    target.onAlert = null
    target.frontMostApp().alert().buttons()["Three"].tap();
    target.delay( 1 );

    check(function () {
      var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
      return textValue === "UIAlertView didDismissWithButtonIndex 3";
    });

    UIATarget.onAlert = function () {
      return false;
    };

    target.frontMostApp().navigationBar().leftButton().tap();
    return false;
  }

  target.frontMostApp().mainWindow().buttons()["Open AlertView"].tap();
  target.delay( 4 );
});

test("----- UIBarButtonItem tap -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().navigationBar().rightButton().tap();

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIBarButtonItem Tapped";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});



test("----- UIBarButtonItem tap -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().buttons()["TapMe"].tap();

  check(function () {
    var textValue = UIATarget.localTarget().frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIButton Tapped";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});





test("----- UISegmentedControl tap -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().segmentedControls()[0].buttons()["Second"].tap();

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISegmentedControl value 1";
  });

  target.frontMostApp().mainWindow().segmentedControls()[0].buttons()["First"].tap();

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISegmentedControl value 0";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});




test("----- UISwitch tap -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().switches()[0].setValue(0);

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISwitch value false";
  });

  target.frontMostApp().mainWindow().switches()[0].setValue(1);

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISwitch value true";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});




test("----- UITextField text -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().textFields()[0].tap();
  // UIATarget.localTarget().frontMostApp().keyboard().typeString("t");// fails if software keyboard is disabled
  target.frontMostApp().mainWindow().textFields()[0].setValue("t");

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UITextField text t";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});





test("----- UISlider value -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().sliders()[0].dragToValue(0.00);

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UISlider value 0.0";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});




test("----- UIDatePicker date -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().pickers()[0].wheels()[0].tapWithOptions({tapOffset:{x:0.49, y:0.65}});
  target.frontMostApp().mainWindow().pickers()[0].wheels()[1].tapWithOptions({tapOffset:{x:0.35, y:0.64}});
  target.frontMostApp().mainWindow().pickers()[0].wheels()[2].tapWithOptions({tapOffset:{x:0.46, y:0.64}});

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIDatePicker date 1970-01-02 00:00:00 +0000";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});




test("----- UIActionSheet tap -----", function (check, pass) {

  target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();

  target.frontMostApp().mainWindow().buttons()["Open ActionSheet"].tap();
  target.frontMostApp().actionSheet().collectionViews()[0].cells()["OK"].buttons()["OK"].tap();

  target.delay( 2 );

  check(function () {
    var textValue = target.frontMostApp().mainWindow().staticTexts()["debugLabel"].value();
    return textValue === "UIActionSheet didDismissWithButtonIndex 0";
  });

  target.frontMostApp().navigationBar().leftButton().tap();
});
