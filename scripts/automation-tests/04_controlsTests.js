
var apiTestIndex = 5

var firstScrollView = function () {
    return UIATarget.localTarget().frontMostApp().mainWindow().scrollViews()[0]
}

var goToControlsScreen = function() {
    var target = UIATarget.localTarget();
    target.frontMostApp().mainWindow().tableViews()[0].cells()[apiTestIndex].tap();
    sleep(1)
}

test("----- UIDatePicker date -----", function (check, pass) {

    goToControlsScreen();

    var scrollView = firstScrollView();

    var picker = scrollView.pickers()[0];
    picker.wheels()[0].tapWithOptions({tapOffset:{x:0.49, y:0.65}});
    picker.wheels()[1].tapWithOptions({tapOffset:{x:0.35, y:0.64}});
    picker.wheels()[2].tapWithOptions({tapOffset:{x:0.46, y:0.64}});

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UIDatePicker date 1970-01-02 00:00:00 +0000";
    });

    goBack();
});

test("----- UIBarButtonItem tap -----", function (check, pass) {
    goToControlsScreen();

    var scrollView = firstScrollView();

    UIATarget.localTarget().frontMostApp().navigationBar().rightButton().tap();

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UIBarButtonItem Tapped";
    });

    goBack();
});


test("----- UIButton tap -----", function (check, pass) {
    goToControlsScreen();

    var scrollView = firstScrollView();
    scrollView.buttons()["TapMe"].tap();

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UIButton Tapped";
    });

    goBack();
});


test("----- UISegmentedControl tap -----", function (check, pass) {
    goToControlsScreen();

    var scrollView = firstScrollView();

    scrollView.segmentedControls()[0].buttons()["Second"].tap();

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UISegmentedControl value 1";
    });

    scrollView.segmentedControls()[0].buttons()["First"].tap();

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UISegmentedControl value 0";
    });

    goBack();
});




test("----- UISwitch tap -----", function (check, pass) {
    goToControlsScreen();

    var scrollView = firstScrollView();

    scrollView.switches()[0].setValue(0);

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UISwitch value false";
    });

    scrollView.switches()[0].setValue(1);

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UISwitch value true";
    });

    goBack();
});


test("----- UITextField text -----", function (check, pass) {

    goToControlsScreen();

    var scrollView = firstScrollView();

    scrollView.textFields()[0].tap();
    typeString("t");

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UITextField text t";
    });

    goBack();
});

test("----- UITextView text -----", function (check, pass) {

    goToControlsScreen();

    var scrollView = firstScrollView();

    scrollView.textViews()[0].tap();
    typeString("t");

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UITextView text t";
    });

    goBack();
});

test("----- UISlider value -----", function (check, pass) {

    goToControlsScreen();

    var scrollView = firstScrollView();

    scrollView.sliders()[0].dragToValue(0.00);

    check(function () {
        var textValue = scrollView.staticTexts()["debugLabel"].value();
        return textValue === "UISlider value 0.0";
    });

    goBack();
});
