rm -rf .build
mkdir .build

products=(RxSwift RxRelay RxCocoa RxTest RxBlocking)
BUILD_PATH=`realpath .build`

for product in ${products[@]}; do
    PROJECT_NAME="$product"

    # Generate iOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-iphoneos.xcarchive" -destination "generic/platform=iOS" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate iOS Simulator framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-iossimulator.xcarchive" -destination "generic/platform=iOS Simulator" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate macOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-macosx.xcarchive" -destination "generic/platform=macOS,name=Any Mac" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate maccatalyst framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-maccatalyst.xcarchive" -destination "generic/platform=macOS,variant=Mac Catalyst" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate tvOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-appletvos.xcarchive" -destination "generic/platform=tvOS" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate tvOS Simulator framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-appletvsimulator.xcarchive" -destination "generic/platform=tvOS Simulator" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate visionOS framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-visionos.xcarchive" -destination "generic/platform=visionOS" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # Generate visionOS simulator framework
    xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-visionossimulator.xcarchive" -destination "generic/platform=visionOS Simulator" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

    # RxTest doesn't work on watchOS 
    if [[ "$product" != "RxTest" ]]; then
        # Generate watchOS framework
        xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-watchos.xcarchive" -destination "generic/platform=watchOS" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

        # Generate watchOS Simulator framework
        xcodebuild -workspace Rx.xcworkspace -configuration Release -archivePath "${BUILD_PATH}/${PROJECT_NAME}-watchsimulator.xcarchive" -destination "generic/platform=watchOS Simulator" SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -scheme $PROJECT_NAME archive | xcbeautify

        # Generate XCFramework
        xcodebuild -create-xcframework \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-iphoneos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-iphoneos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-iossimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-iossimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-macosx.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-macosx.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-maccatalyst.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-maccatalyst.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-watchos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-watchos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-watchsimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-watchsimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-appletvos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-appletvos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-appletvsimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-appletvsimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-visionos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-visionos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-visionossimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-visionossimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -output "./${PROJECT_NAME}.xcframework" | xcbeautify
    else
        # Generate XCFramework
        xcodebuild -create-xcframework \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-iphoneos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-iphoneos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-iossimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-iossimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-macosx.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-macosx.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-maccatalyst.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-maccatalyst.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-appletvos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-appletvos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-appletvsimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-appletvsimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-visionos.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-visionos.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -framework "${BUILD_PATH}/${PROJECT_NAME}-visionossimulator.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
        -debug-symbols "${BUILD_PATH}/${PROJECT_NAME}-visionossimulator.xcarchive/dSYMs/${PROJECT_NAME}.framework.dSYM" \
        -output "./${PROJECT_NAME}.xcframework" | xcbeautify
    fi

    # Code sign the binary
    codesign -v --sign "RxSwift Distribution" "./${PROJECT_NAME}.xcframework"
done

# Zip all frameworks to a single ZIP
# This is (unfortunately) required by Carthage to work: https://bit.ly/3LVm0Y9
zip -r ./RxSwift.xcframework.zip *.xcframework
