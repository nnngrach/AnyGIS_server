// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "AnyGIS_Server",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0") //,
        
        // Устанавливаю дополнение, чтобы сохранять файлы на сервер
        //.package(url: "https://github.com/nodes-vapor/storage.git", from: "1.0.0-beta")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor" /*, "Storage"*/]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

