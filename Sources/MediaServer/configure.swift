import Leaf
import Vapor

public func configure(_ app: Application) async throws {
    app.views.use(.leaf)
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try routes(app)
}
