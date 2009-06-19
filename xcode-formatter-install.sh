#! /bin/sh

# http://developer.apple.com/SampleCode/WcharDataFormatter/

xcodebuild -target "Xcode Formatter" -configuration "Release" clean
xcodebuild -target "Xcode Formatter" -configuration "Release"

# /Developer/Library/Xcode/CustomDataViews/

# /Library/Application Support/Apple/Developer Tools/CustomDataViews ???
# (/Library/Application Support/Developer/Shared/Xcode exists)

BUNDLE_NAME=CHDataStructuresFormatter.bundle
INSTALL_PATH=~/Library/Application\ Support/Xcode/CustomDataViews

mkdir -p "$INSTALL_PATH"
rm -rf "$INSTALL_PATH/$BUNDLE_NAME"
cp -R build/Release/$BUNDLE_NAME "$INSTALL_PATH"
