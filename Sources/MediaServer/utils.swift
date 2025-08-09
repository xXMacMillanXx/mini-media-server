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

    /// Default returnes everything recursive
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
            includingPropertiesForKeys: [.isDirectoryKey],
            options: options
        ) {
            for case let fileURL as URL in enumerator {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
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
}
