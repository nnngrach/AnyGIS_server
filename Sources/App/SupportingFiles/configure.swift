import FluentSQLite
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    
    /// Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)

    
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)base.sqlite"))
    
    let tempStorage = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)tempStorage.sqlite"))

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    databases.add(database: tempStorage, as: .tempStorage)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: MapsList.self, database: .sqlite)
    migrations.add(model: OverlayMapsList.self, database: .sqlite)
    migrations.add(model: PriorityMapsList.self, database: .sqlite)
    migrations.add(model: MirrorsMapsList.self, database: .sqlite)
    migrations.add(model: ServiceData.self, database: .sqlite)
    
    migrations.add(model: TempStorage.self, database: .tempStorage)
    services.register(migrations)
}
