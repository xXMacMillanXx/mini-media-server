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

let supported = [
    "video": [".mp4", ".webm", ".ogg"],
    "audio": [".mp3", ".wav", ".ogg"],
    "image": [
        ".apng", ".gif", ".ico", ".cur", ".jpg", ".jpeg", ".jfif", ".pjpeg", ".pjp", ".png", ".svg",
        ".webp",
    ],
    "document": [".pdf"],
    "web": [".link"],
]

var supportedMedia: [String] {
    var supportedFormats: [String] = []
    for fileFormats in supported.values {
        supportedFormats += fileFormats
    }
    return supportedFormats
}

func contentFilter(name: String) -> Bool {
    for videoFormat in supportedMedia {
        if name.hasSuffix(videoFormat) {
            return true
        }
    }
    return false
}

/* TODO
 * - change player dependent on media (video, autio, document, ...)
 * - Videos with [] in name have %20 instead of spaces...
*/

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        let mainSource = "/media/"
        req.session.data["rootdir"] = mainSource
        req.session.data["dir"] = mainSource
        let videoDirectory = "\(app.directory.publicDirectory)\(mainSource)"
        let videoPath = "\(mainSource)"

        var links = Utils.getFilesAndDirectories(atPath: videoDirectory)
        if req.session.data["dir"] == req.session.data["rootdir"] {
            links.directories.removeFirst()
        }

        return req.view.render(
            "index",
            IndexContext(
                path: mainSource, sidebarLinks: links.files, sidebarDirectories: links.directories,
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

        var links = Utils.getFilesAndDirectories(atPath: "\(app.directory.publicDirectory)\(path)")
        if req.session.data["dir"] == req.session.data["rootdir"] {
            links.directories.removeFirst()
        }

        return try await req.view.render(
            "sidebar",
            SidebarContext(
                path: path, sidebarLinks: links.files.filter(contentFilter),
                sidebarDirectories: links.directories))
    }

    app.get("sidebarsearch") { req -> View in
        let dir = req.session.data["dir"] ?? ""
        var links = Utils.getFilesAndDirectories(atPath: "\(app.directory.publicDirectory)\(dir)")
        if req.session.data["dir"] == req.session.data["rootdir"] {
            links.directories.removeFirst()
        }

        return try await req.view.render(
            "sidebar",
            SidebarContext(
                path: dir, sidebarLinks: links.files.filter(contentFilter),
                sidebarDirectories: links.directories))
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
            SidebarContext(
                path: dir, sidebarLinks: files.filter(contentFilter),
                sidebarDirectories: directories))
    }
}
