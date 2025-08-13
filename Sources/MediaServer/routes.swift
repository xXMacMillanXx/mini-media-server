import Vapor

struct VideoContext: Encodable {
    let videoTag: String
}

struct AudioContext: Encodable {
    let audioTag: String
}

struct ImageContext: Encodable {
    let imageTag: String
}

struct DocumentContext: Encodable {
    let documentTag: String
}

struct WebContext: Encodable {
    let webTag: String
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

let supported: [String: Set<String>] = [
    "video": [".mp4", ".webm", ".ogg"],
    "audio": [".mp3", ".wav", ".ogg", ".flac"],
    "image": [
        ".apng", ".gif", ".ico", ".cur", ".jpg", ".jpeg", ".jfif", ".pjpeg", ".pjp", ".png", ".svg",
        ".webp",
    ],
    "document": [".pdf"],
    "web": [".link"],
]

var supportedMediaGen: Set<String> {
    var supportedFormats = Set<String>()
    for fileFormats in supported.values {
        supportedFormats.formUnion(fileFormats)
    }
    return supportedFormats
}
let supportedMedia = supportedMediaGen

func contentFilter(name: String) -> Bool {
    if let index = name.lastIndex(of: ".") {
        if supportedMedia.contains(name.suffix(from: index).lowercased()) {
            return true
        }
    }
    return false
}

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
        guard  // rm and add seems stupid, but if [ or ] is included only parts are encoded T-T
            let path = req.parameters.getCatchall().joined(separator: "/").removingPercentEncoding?
                .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed),
            let index = path.lastIndex(of: ".")
        else {
            return try await req.view.render("content")
        }

        func handles(filetype supportName: String) -> Bool {
            supported[supportName]?.contains(path.suffix(from: index).lowercased()) ?? false
        }

        func contentView(_ context: any Encodable) async throws -> View {
            return try await req.view.render("content", context)
        }

        if handles(filetype: "video") {
            return try await contentView(VideoContext(videoTag: path))
        } else if handles(filetype: "audio") {
            return try await contentView(AudioContext(audioTag: path))
        } else if handles(filetype: "image") {
            return try await contentView(ImageContext(imageTag: path))
        } else if handles(filetype: "document") {
            return try await contentView(DocumentContext(documentTag: path))
        } else if handles(filetype: "web") {
            if let fileContent = try? String(
                contentsOfFile:
                    "\(app.directory.publicDirectory)\(path.removingPercentEncoding ?? "")",
                encoding: String.Encoding.utf8)
            {
                return try await contentView(WebContext(webTag: fileContent))
            }
        }

        return try await req.view.render("content")
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
            $0.lowercased().hasPrefix(search.lowercased())
        })
        let directories = Utils.getDirectories(atPath: "\(app.directory.publicDirectory)\(dir)")
            .filter({
                $0.lowercased().hasPrefix(search.lowercased())
            })

        return try await req.view.render(
            "sidebar",
            SidebarContext(
                path: dir, sidebarLinks: files.filter(contentFilter),
                sidebarDirectories: directories))
    }
}
