import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("video") { req -> EventLoopFuture<View> in
        let videoDirectory = "\(app.directory.publicDirectory)/videos/"
        let fileManager = FileManager.default

        guard let files = try? fileManager.contentsOfDirectory(atPath: videoDirectory),
            let randomFile = files.filter({ $0.hasSuffix(".mp4") || $0.hasSuffix(".webm") })
                .randomElement()
        else {
            throw Abort(.notFound, reason: "No video files found.")
        }

        let videoPath = "/videos/\(randomFile)"

        struct VideoContext: Encodable {
            let videoTag: String
        }

        return req.view.render("video", VideoContext(videoTag: videoPath))
    }
}
