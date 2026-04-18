import Foundation

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
}
