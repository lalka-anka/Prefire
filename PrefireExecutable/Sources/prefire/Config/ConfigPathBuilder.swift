import Foundation

enum ConfigPathBuilder {
    private static let configFileName = ".prefire.yml"
    
    /// Unifying the format of the config path and creating additional possible paths
    /// - Parameter configPath: The current path to the config, or `nil` if not provided
    /// - Parameter testTargetPath: Path to Snapshot Tests Target
    /// - Returns: An array of possible paths for the configuration file
    static func possibleConfigPaths(for configPath: String?, testTargetPath: String?) -> [String] {
        var possibleConfigPaths = [String]()

        if var configPath = configPath {
            // Check if the provided path is absolute and remove leading slash if so
            if configPath.hasPrefix("/") {
                configPath.removeFirst()
            }
            if configPath.hasSuffix("/") {
                configPath.removeLast()
            }

            possibleConfigPaths.append(configPath)
            possibleConfigPaths.append(FileManager.default.currentDirectoryPath + "/\(configPath)")

            if !configPath.hasSuffix(configFileName) {
                possibleConfigPaths = possibleConfigPaths.map { $0 + "/\(configFileName)" } // Дополняем путь названием файла, если его там нет
            }

            let subfolderPaths = findConfigPathsRecursively(in: configPath)
            possibleConfigPaths.append(contentsOf: subfolderPaths)
        } else {
            // Add the default path if no specific one is provided
            possibleConfigPaths.append(FileManager.default.currentDirectoryPath + "/\(configFileName)")
        }

        if let testTargetPath {
            possibleConfigPaths.insert(testTargetPath + "/\(configFileName)", at: 0)
        }

        return possibleConfigPaths
    }

    private static func findConfigPathsRecursively(in path: String) -> [String] {
        var resultPaths = [String]()

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)

            for item in contents {
                let fullPath = (path as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        resultPaths.append(contentsOf: findConfigPathsRecursively(in: fullPath))
                    } else if item == configFileName {
                        resultPaths.append(fullPath)
                    }
                }
            }
        } catch {
            print("Error while exploring directory: \(path)")
        }

        return resultPaths
    }
}
