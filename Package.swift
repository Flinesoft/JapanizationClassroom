// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "JapanizationClassroom",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),

        // 🖋🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // Handy Swift features that didn't make it into the Swift standard library.
        .package(url: "https://github.com/Flinesoft/HandySwift.git", from: "2.7.0"),

        // The better way to deal with JSON data in Swift.
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.2.0"),

        // Lightweight User-Agent String Parser (Port of ua-parser.js in Swift)
        .package(url: "https://github.com/malcommac/UAParserSwift.git", from: "1.0.1"),
    ],
    targets: [
        .target(name: "App", dependencies: ["UAParserSwift", "SwiftyJSON", "HandySwift", "FluentPostgreSQL", "Leaf", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

