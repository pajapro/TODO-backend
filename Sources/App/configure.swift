import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register ORM provider
    try services.register(FluentPostgreSQLProvider())
	
	/// Register authentication provider
	try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Register PostgreSQL database
	let psqlConfig: PostgreSQLDatabaseConfig
	if let url = Environment.get("DATABASE_URL"), let dbConfig = PostgreSQLDatabaseConfig(url: url) { // it will read from this URL in production
		psqlConfig = dbConfig
		print("Registered DB from DATABASE_URL")
	} else { // when environment variable not present, default to local development environment
		psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "vapor", database: "vapor", password: "password")
		print("Registered local DB")
	}
	let psqlDatabase = PostgreSQLDatabase(config: psqlConfig)
	var dbConfig = DatabasesConfig()
    /// Register the configured PostgreSQL database to the database config
    dbConfig.add(database: psqlDatabase, as: .psql)
    // Enable logging on the SQLite database
    dbConfig.enableLogging(on: .psql)
    services.register(dbConfig)

    /// Register model migrations
    var migrations = MigrationConfig()
    migrations.add(model: Task.self, database: .psql)
    migrations.add(model: List.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
	migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
}
