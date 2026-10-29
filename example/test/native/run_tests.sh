#!/bin/sh
# Runs the APNs coordinator tests on macOS without signing or an iOS device.
set -eu
native_tests_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
example_root=$(CDPATH= cd -- "$native_tests_dir/../.." && pwd)
xcode_developer_dir=$(xcode-select -p)
platform_developer_dir="$xcode_developer_dir/Platforms/MacOSX.platform/Developer"
apns_test_build_dir=$(mktemp -d /tmp/sendsay-apns-tests.XXXXXX)
trap 'rm -rf "$apns_test_build_dir"' EXIT HUP INT TERM

xcrun swiftc -emit-library -emit-module -enable-testing \
    -module-name APNsTracker \
    -emit-module-path "$apns_test_build_dir/APNsTracker.swiftmodule" \
    -module-cache-path "$apns_test_build_dir/cache" \
    -o "$apns_test_build_dir/libAPNsTracker.dylib" \
    "$example_root/ios/Runner/APNsTokenTracker.swift"

xcrun swiftc \
    -I "$apns_test_build_dir" -L "$apns_test_build_dir" -lAPNsTracker \
    -I "$platform_developer_dir/usr/lib" \
    -L "$platform_developer_dir/usr/lib" \
    -F "$platform_developer_dir/Library/Frameworks" \
    -F "$platform_developer_dir/Library/PrivateFrameworks" \
    -Xlinker -rpath -Xlinker "$apns_test_build_dir" \
    -Xlinker -rpath -Xlinker "$platform_developer_dir/usr/lib" \
    -Xlinker -rpath -Xlinker "$platform_developer_dir/Library/Frameworks" \
    -Xlinker -rpath -Xlinker "$platform_developer_dir/Library/PrivateFrameworks" \
    -module-cache-path "$apns_test_build_dir/cache" \
    "$native_tests_dir/APNsTokenTrackerTests.swift" \
    "$native_tests_dir/main.swift" \
    -o "$apns_test_build_dir/run-tests"

"$apns_test_build_dir/run-tests"
