import Foundation

/// Utility to find and list supported media files within a directory.
class FolderScanner {
    
    static let supportedExtensions = ["jpg", "jpeg", "png", "heic", "tiff", "mov", "mp4", "m4v"]
    
    /// Scans a directory for supported files.
    static func scan(at url: URL) -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []
        
        let keys: [URLResourceKey] = [.isRegularFileKey, .nameKey]
        
        guard let enumerator = fileManager.enumerator(at: url,
                                                       includingPropertiesForKeys: keys,
                                                       options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return []
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
                if resourceValues.isRegularFile == true {
                    let ext = fileURL.pathExtension.lowercased()
                    if supportedExtensions.contains(ext) {
                        results.append(fileURL)
                    }
                }
            } catch {
                print("Error scanning file: \(error)")
            }
        }
        
        return results
    }
}
