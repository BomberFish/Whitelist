all: build package clean

PROJECT = $(shell basename *.xcodeproj)
WORKING_LOCATION := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TARGET = Whitelist
CONFIGURATION = Release
SDK = iphoneos

build:
	echo "Building $(TARGET) for $(SDK)..."
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIGURATION) -sdk $(SDK) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO clean build
	echo "Build finished!"

entitlements:
	echo "Adding entitlements"
	chmod a+x $WORKING_LOCATION/bin/ldid
	$WORKING_LOCATION/bin/ldid -S"$WORKING_LOCATION/entitlements.plist" "$TARGET_APP/$APPLICATION_NAME"

package:
	rm -rf Payload
	mkdir Payload
	cp -r build/$(CONFIGURATION)-$(SDK)/$(TARGET).app Payload
	zip -r $(TARGET).ipa Payload

clean:
	rm -rf Payload
	rm -rf build

