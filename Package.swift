// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "server", // Set the project name here
    dependencies: [
        .package(url: "https://github.com/yene/GCDWebServer.git", from: "3.5.7") // Update version as needed
    ],
    targets: [
        .executableTarget(
            name: "server", // Set the executable target name here
            dependencies: ["GCDWebServer"]),
    ]
)
