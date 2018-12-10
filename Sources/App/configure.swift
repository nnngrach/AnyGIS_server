import FluentSQLite
import Vapor
import Storage

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    
    // Дописал!!
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    /*
    
    // Дописал!! Дополнение для сохранения файлов
    let driver = try S3Driver(
        bucket: "MyBucket",
        accessKey: "key",
        secretKey: "secret",
        region: .usWest2
    )
    
    services.register(driver, as: NetworkDriver.self)
    
   */
    
    // Configure a SQLite database
    //let sqlite = try SQLiteDatabase(storage: .memory)
//    let sqlite = try SQLiteDatabase(storage: .file(path: "/Projects/GIS/AnyGIS server/AnyGIS_Server/Sources/App/Models of Data/base.sqlite"))
    let sqlite = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)base.sqlite"))

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: MapData.self, database: .sqlite)
    services.register(migrations)

}
