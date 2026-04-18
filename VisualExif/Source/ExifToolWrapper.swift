import Foundation

struct MetadataEntry: Identifiable, Codable {
    var id: String { key }
    let key: String
    let value: String
    
    // Supporting dynamic keys from JSON
    enum CodingKeys: String, CodingKey {
        case key, value
    }
}

/// A robust wrapper to communicate with the bundled ExifTool Perl script.
class ExifToolWrapper {
    
    enum ExifCategory: String, CaseIterable {
        case gps = "GPS"
        case exif = "EXIF"
        case iptc = "IPTC"
        case xmp = "XMP"
        case makerNotes = "MakerNotes"
        case all = "All"
        
        var command: String {
            switch self {
            case .gps: return "-GPS:*="
            case .exif: return "-EXIF:*="
            case .iptc: return "-IPTC:*="
            case .xmp: return "-XMP:*="
            case .makerNotes: return "-MakerNotes:*="
            case .all: return "-all="
            }
        }
    }
    
    static let shared = ExifToolWrapper()
    
    private var exifToolURL: URL? {
        return Bundle.main.url(forResource: "exiftool", withExtension: nil, subdirectory: "ExifTool")
    }
    
    /// Executes ExifTool with specific arguments on a target file or directory.
    func process(path: String, categories: Set<ExifCategory>, completion: @escaping (Bool, String) -> Void) {
        guard let toolURL = exifToolURL else {
            completion(false, "ExifTool not found in bundle.")
            return
        }
        
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = toolURL
        
        // Build arguments
        var args = categories.map { $0.command }
        args.append("-overwrite_original") // Don't create _original files to keep it simple
        args.append(path)
        
        task.arguments = args
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            if task.terminationStatus == 0 {
                completion(true, String(data: data, encoding: .utf8) ?? "Success")
            } else {
                let errorMsg = String(data: errorData, encoding: .utf8) ?? "Unknown Error"
                completion(false, errorMsg)
            }
        } catch {
            completion(false, "Failed to run process: \(error.localizedDescription)")
        }
    }
    
    /// Reads metadata from a file and returns an array of entries.
    func read(path: String, completion: @escaping ([MetadataEntry]?) -> Void) {
        guard let toolURL = exifToolURL else {
            completion(nil)
            return
        }
        
        let task = Process()
        let pipe = Pipe()
        
        task.executableURL = toolURL
        task.arguments = ["-j", "-G1", "-s", path] // -j for JSON, -G1 for group names, -s for short names
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            // ExifTool -j returns an array of objects [ { ... } ]
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstObject = json.first {
                
                var entries: [MetadataEntry] = []
                for (key, value) in firstObject {
                    // Skip technical keys like SourceFile
                    if key == "SourceFile" { continue }
                    entries.append(MetadataEntry(key: key, value: "\(value)"))
                }
                
                // Sort by key name for consistency
                entries.sort { $0.key < $1.key }
                completion(entries)
            } else {
                completion(nil)
            }
        } catch {
            print("Error reading metadata: \(error)")
            completion(nil)
        }
    }
}
