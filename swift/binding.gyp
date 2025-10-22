{
  "targets": [
    {
      "target_name": "swift_addon",
      "conditions": [
        [
          'OS=="mac"',
          {
            "sources": [
              "src/swift_addon.mm",
              "src/SwiftBridge.m"
            ],
            "include_dirs": [
              "<!@(node -p \"require('node-addon-api').include\")",
              "include",
              "build_swift",
              "Sources/SwiftCode",
              ".build/arm64-apple-macosx/release/Modules"
            ],
            "dependencies": [
              "<!(node -p \"require('node-addon-api').gyp\")"
            ],
            "libraries": [
              "<(PRODUCT_DIR)/libSwiftCode.a"
            ],
            "cflags!": [ "-fno-exceptions" ],
            "cflags_cc!": [ "-fno-exceptions" ],
            "xcode_settings": {
              "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
              "CLANG_ENABLE_OBJC_ARC": "YES",
              "SWIFT_OBJC_BRIDGING_HEADER": "include/SwiftBridge.h",
              "SWIFT_VERSION": "5.0",
              "SWIFT_OBJC_INTERFACE_HEADER_NAME": "swift_addon-Swift.h",
              "MACOSX_DEPLOYMENT_TARGET": "11.0",
              "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
              "OTHER_CFLAGS": [
                "-ObjC++",
                "-fobjc-arc"
              ],
              "OTHER_LDFLAGS": [
                "-Wl,-rpath,@loader_path",
                "-Wl,-rpath,/usr/lib/swift",
                "-Wl,-rpath,@executable_path/../Frameworks",
                "-framework", "Foundation",
                "-lsqlite3",
                "-lc++"
              ],
              "HEADER_SEARCH_PATHS": [
                "$(SRCROOT)/include",
                "$(CONFIGURATION_BUILD_DIR)",
                "$(SRCROOT)/build/Release",
                "$(SRCROOT)/build_swift"
              ],
              "LIBRARY_SEARCH_PATHS": [
                "/usr/lib/swift",
                "$(TOOLCHAIN_DIR)/usr/lib/swift/macosx"
              ]
            },
            "actions": [
              {
                "action_name": "build_swift_deps",
                "inputs": [
                  "Package.swift"
                ],
                "outputs": [
                  ".build/arm64-apple-macosx/release/Modules/SQLite.swiftmodule"
                ],
                "action": [
                  "sh",
                  "-c",
                  "cd <(module_root_dir) && swift build -c release"
                ]
              },
              {
                "action_name": "build_swift",
                "inputs": [
                  "Sources/SwiftCode/SwiftCode.swift",
                  "Sources/SwiftCode/db/DBConnection.swift",
                  "Sources/SwiftCode/db/SQLManager.swift",
                  ".build/arm64-apple-macosx/release/Modules/SQLite.swiftmodule"
                ],
                "outputs": [
                  "build_swift/libSwiftCode.a",
                  "build_swift/swift_addon-Swift.h"
                ],
                "action": [
                  "sh",
                  "-c",
                  "cd <(module_root_dir) && mkdir -p build_swift && swiftc -emit-library -emit-objc-header -emit-objc-header-path build_swift/swift_addon-Swift.h -module-name swift_addon -import-objc-header include/SwiftBridge.h -static -o build_swift/libSwiftCode.a Sources/SwiftCode/SwiftCode.swift Sources/SwiftCode/db/DBConnection.swift Sources/SwiftCode/db/SQLManager.swift -I .build/arm64-apple-macosx/release/Modules .build/arm64-apple-macosx/release/SQLite.build/*.o -target arm64-apple-macosx11.0 -sdk `xcrun --show-sdk-path`"
                ]
              },
              {
                "action_name": "copy_swift_lib",
                "inputs": [
                  "<(module_root_dir)/build_swift/libSwiftCode.a"
                ],
                "outputs": [
                  "<(PRODUCT_DIR)/libSwiftCode.a"
                ],
                "action": [
                  "sh",
                  "-c",
                  "cp -f <(module_root_dir)/build_swift/libSwiftCode.a <(PRODUCT_DIR)/libSwiftCode.a"
                ]
              }
            ]
          }
        ]
      ]
    }
  ]
}
