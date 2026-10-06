// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Marronniers",
    products: [
        .library(name: "Marronniers", targets: ["Marronniers"])
    ],
    targets: [
        .target(name: "Marronniers", path: "Sources/Marronniers"),
        .testTarget(name: "MarronniersTests", dependencies: ["Marronniers"], path: "Tests/MarronniersTests")
    ]
)
