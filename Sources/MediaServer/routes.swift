import Vapor

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        let videoDirectory = "\(app.directory.publicDirectory)/videos/"

        let files = Utils.getFiles(atPath: videoDirectory)
        guard let randomFile = files.filter({ $0.hasSuffix(".mp4") }).randomElement() else {
            throw Abort(.notFound, reason: "No video files found.")
        }

        let videoPath = "/videos/\(randomFile)"
        let links = Utils.getFiles(atPath: videoDirectory)
        req.session.data["dir"] = "/videos/"

        struct VideoContext: Encodable {
            let path: String
            let sidebarLinks: [String]
            let videoTag: String
        }

        return req.view.render(
            "index", VideoContext(path: "/videos/", sidebarLinks: links, videoTag: videoPath))
    }

    app.get("content", "**") { req -> View in
        let path = req.parameters.getCatchall().joined(separator: "/")
        return try await req.view.render("video", ["videoTag": path])
    }

    app.get("sidebarsearch") { req -> View in
        let dir = req.session.data["dir"] ?? ""
        let files = Utils.getFiles(atPath: "\(app.directory.publicDirectory)\(dir)")

        struct SidebarContext: Encodable {
            let path: String
            let sidebarLinks: [String]
        }

        return try await req.view.render(
            "sidebar", SidebarContext(path: dir, sidebarLinks: files))
    }

    app.get("sidebarsearch", ":search") { req -> View in
        let dir = req.session.data["dir"] ?? ""
        let search = req.parameters.get("search") ?? ""

        let files = Utils.getFiles(atPath: "\(app.directory.publicDirectory)\(dir)").filter({
            $0.hasPrefix(search)
        })
        struct SidebarContext: Encodable {
            let path: String
            let sidebarLinks: [String]
        }

        return try await req.view.render(
            "sidebar", SidebarContext(path: dir, sidebarLinks: files))
    }
}
