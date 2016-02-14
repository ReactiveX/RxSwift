
#import "common.js"
#import "01_githubSignUp.js"
#import "02_searchWikipedia.js"
#import "03_masterDetail.js"
#import "04_controlsTests.js"
#import "05_reactivePartialUpdates.js"

var target = UIATarget.localTarget();

// open all screens
for (var i = 0; i < 14; ++i) {
  log(i);
  target.delay( 0.5 );
  target.frontMostApp().mainWindow().tableViews()[0].cells()[i].tap();
  target.frontMostApp().navigationBar().leftButton().tap();
}
