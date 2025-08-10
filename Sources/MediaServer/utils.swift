import Foundation

class Utils {
    static let fileManager = FileManager.default

    /// Returned directories are shallow
    static func getDirectories(atPath path: String) -> [String] {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            let directories = contents.filter { item in
                var isDir: ObjCBool = false
                let fullPath = (path as NSString).appendingPathComponent(item)
                _ = fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
                return isDir.boolValue
            }
            return directories.sorted()
        } catch {
            return []
        }
    }

    /// Returned files are shallow
    static func getFiles(atPath path: String) -> [String] {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            let files = contents.filter { item in
                var isDir: ObjCBool = false
                let fullPath = (path as NSString).appendingPathComponent(item)
                _ = fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
                return !isDir.boolValue
            }
            return files.sorted()
        } catch {
            return []
        }
    }

    /// Returned files and directories are shallow
    static func getFilesAndDirectories(atPath path: String) -> (
        root: String, files: [String], directories: [String]
    ) {
        var files: [String] = []
        var dicts: [String] = []

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for elem in contents {
                var isDir: ObjCBool = false
                let fullPath = (path as NSString).appendingPathComponent(elem)
                _ = fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
                if isDir.boolValue {
                    dicts.append(elem)
                } else {
                    files.append(elem)
                }
            }
        } catch {
            print("[Error] Issue with getting info for \(path)")
        }

        return (root: path, files: files.sorted(), directories: dicts.sorted())
    }

    /// Returns files and directories deep
    static func getFilesAndDirectoriesDeep(atPath path: String) -> (
        files: [String], directories: [String]
    ) {
        let contents = getFilesAndDirectories(atPath: path)
        var ret_files: [String] = []
        var ret_dirs: [String] = []

        func walk(content: (root: String, files: [String], directories: [String])) {
            for file in content.files {
                ret_files.append("\(content.root)/\(file)")
            }
            ret_dirs.append(content.root)

            for dir in content.directories {
                let ncon = getFilesAndDirectories(atPath: "\(content.root)/\(dir)")
                walk(content: ncon)
            }
        }

        walk(content: contents)

        return (files: ret_files.sorted(), directories: ret_dirs.sorted())
    }

    /*
    /// Default returnes everything recursive, but doesn't work with symbolic links
    static func getFilesAndDictionaries(atPath path: String, shallowSearch shallow: Bool = false)
        -> (
            files: [String], dictionaries: [String]
        )
    {
        let rootURL = URL(fileURLWithPath: path)
        var files: [String] = []
        var dicts: [String] = []

        var options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        if shallow {
            options = [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        }

        if let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: options
        ) {
            for case let fileURL as URL in enumerator {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [
                        .isDirectoryKey, .isSymbolicLinkKey,
                    ])
                    if resourceValues.isDirectory == true {
                        dicts.append(fileURL.path)
                    } else {
                        files.append(fileURL.path)
                    }
                } catch {
                    print("Error reading \(fileURL):", error)
                }
            }
        }
        return (files: files.sorted(), dictionaries: dicts.sorted())
    }
    */
}
