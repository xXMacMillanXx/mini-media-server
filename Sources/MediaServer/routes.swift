import Vapor

struct VideoContext: Encodable {
    let videoTag: String
}

struct SidebarContext: Encodable {
    let path: String
    let sidebarLinks: [String]
    let sidebarDirectories: [String]
}

struct IndexContext: Encodable {
    let path: String
    let sidebarLinks: [String]
    let sidebarDirectories: [String]
    let videoTag: String
}

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        let videoDirectory = "\(app.directory.publicDirectory)/videos/"

        let files = Utils.getFiles(atPath: videoDirectory)
        guard let randomFile = files.filter({ $0.hasSuffix(".mp4") }).randomElement() else {
            throw Abort(.notFound, reason: "No video files found.")
        }

        let videoPath = "/videos/\(randomFile)"
        let links = Utils.getFilesAndDirectories(atPath: videoDirectory)
        req.session.data["dir"] = "/videos/"

        return req.view.render(
            "index",
            IndexContext(
                path: "/videos/", sidebarLinks: links.files, sidebarDirectories: links.directories,
                videoTag: videoPath
            ))
    }

    app.get("content", "**") { req -> View in
        let path = req.parameters.getCatchall().joined(separator: "/")
        return try await req.view.render("video", VideoContext(videoTag: path))
    }

    app.get("contentdirectory", "**") { req -> View in
        let path = "/\(req.parameters.getCatchall().joined(separator: "/"))/"
        req.session.data["dir"] = path

        let links = Utils.getFilesAndDirectories(atPath: "\(app.directory.publicDirectory)\(path)")

        return try await req.view.render(
            "sidebar",
            SidebarContext(
                path: path, sidebarLinks: links.files, sidebarDirectories: links.directories))
    }

    app.get("sidebarsearch") { req -> View in
        let dir = req.session.data["dir"] ?? ""
        let links = Utils.getFilesAndDirectories(atPath: "\(app.directory.publicDirectory)\(dir)")

        return try await req.view.render(
            "sidebar",
            SidebarContext(
                path: dir, sidebarLinks: links.files, sidebarDirectories: links.directories))
    }

    app.get("sidebarsearch", ":search") { req -> View in
        let dir = req.session.data["dir"] ?? ""
        let search = req.parameters.get("search") ?? ""

        let files = Utils.getFiles(atPath: "\(app.directory.publicDirectory)\(dir)").filter({
            $0.hasPrefix(search)
        })
        let directories = Utils.getDirectories(atPath: "\(app.directory.publicDirectory)\(dir)")
            .filter({
                $0.hasPrefix(search)
            })

        return try await req.view.render(
            "sidebar",
            SidebarContext(path: dir, sidebarLinks: files, sidebarDirectories: directories))
    }
}
