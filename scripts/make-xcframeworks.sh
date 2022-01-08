rm -rf .build
mkdir .build

products=(RxSwift RxRelay RxCocoa RxTest RxBlocking)

for product in ${products[@]}; do
    PROJECT_NAME="$product"

    # Generate iOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-iphoneos.xcarchive" -destination "generic/platform=iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

    # Generate iOS Simulator framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-iossimulator.xcarchive" -destination "generic/platform=iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

    # Generate macOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-macosx.xcarchive" -destination "generic/platform=macOS,name=Any Mac" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

    # Generate tvOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-appletvos.xcarchive" -destination "generic/platform=tvOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

    # Generate tvOS Simulator framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-appletvsimulator.xcarchive" -destination "generic/platform=tvOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

    # RxTest doesn't work on watchOS 
    if [[ "$product" != "RxTest" ]]; then
        # Generate watchOS framework
        xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-watchos.xcarchive" -destination "generic/platform=watchOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

        # Generate watchOS Simulator framework
        xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath ".build/${PROJECT_NAME}-watchsimulator.xcarchive" -destination "generic/platform=watchOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive

        # Generate XCFramework
        xcodebuild -create-xcframework \
        -framework ".build/${PROJECT_NAME}-iphoneos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-iossimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-macosx.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-watchos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-watchsimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-appletvos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-appletvsimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -output "./${PROJECT_NAME}.xcframework"
    else
        # Generate XCFramework
        xcodebuild -create-xcframework \
        -framework ".build/${PROJECT_NAME}-iphoneos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-iossimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-macosx.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-appletvos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -framework ".build/${PROJECT_NAME}-appletvsimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -output "./${PROJECT_NAME}.xcframework"
    fi

    # Zip it!
    zip -r "./${PROJECT_NAME}.xcframework.zip" "./${PROJECT_NAME}.xcframework"
    rm -rf "./${PROJECT_NAME}.xcframework"
done


