import SwiftUI

struct ContentView: View {
    @State private var selectedPath: String = ""
    @State private var filesToProcess: [URL] = []
    @State private var selectedCategories: Set<ExifToolWrapper.ExifCategory> = [.gps]
    @State private var isProcessing = false
    @State private var progress: Double = 0
    @State private var statusMessage = "Drag a folder or images here"
    @State private var showFileImporter = false
    
    // Inspector State
    @State private var inspectorEntries: [MetadataEntry] = []
    @State private var isScanningMetadata = false
    @State private var selectedFileURL: URL?
    
    var body: some View {
        HStack(spacing: 0) {
            // Main Content Area
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("VisualExif")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    Button(action: { showFileImporter = true }) {
                        Label("Select Folder", systemImage: "folder.badge.plus")
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                .background(Color.black.opacity(0.1))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Drop Zone / File Info
                        VStack {
                            if filesToProcess.isEmpty {
                                DropZoneView(status: $statusMessage) { urls in
                                    handleDroppedURLs(urls)
                                }
                            } else {
                                ProcessedFilesView(files: filesToProcess, onClear: {
                                    filesToProcess = []
                                    inspectorEntries = []
                                    selectedFileURL = nil
                                    statusMessage = "Drag a folder or images here"
                                })
                            }
                        }
                        .padding(.horizontal)
                        
                        // Options
                        TagSelectorView(selectedCategories: $selectedCategories)
                            .padding(.horizontal)
                        
                        // Action Section
                        VStack(spacing: 16) {
                            if isProcessing {
                                ProgressView(value: progress)
                                    .progressViewStyle(.linear)
                                    .tint(.blue)
                                Text("Processing \(Int(progress * 100))%")
                                    .font(.caption)
                            } else {
                                Button(action: startCleaning) {
                                    Text("Neutralize Metadata")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(filesToProcess.isEmpty ? Color.gray : Color.blue)
                                        .cornerRadius(12)
                                }
                                .disabled(filesToProcess.isEmpty || selectedCategories.isEmpty)
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(24)
                    }
                    .padding(.vertical)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Inspector Panel
            MetadataInspectorView(entries: inspectorEntries, isLoading: isScanningMetadata)
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(white: 0.05).ignoresSafeArea())
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    handleFolderSelection(url)
                }
            case .failure(let error):
                statusMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func handleDroppedURLs(_ urls: [URL]) {
        var allFiles: [URL] = []
        for url in urls {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    allFiles.append(contentsOf: FolderScanner.scan(at: url))
                } else {
                    allFiles.append(url)
                }
            }
        }
        filesToProcess = allFiles
        statusMessage = "\(allFiles.count) files detected"
        
        // Inspect the first file
        if let first = allFiles.first {
            inspectFile(first)
        }
    }
    
    private func handleFolderSelection(_ url: URL) {
        _ = url.startAccessingSecurityScopedResource()
        let scanned = FolderScanner.scan(at: url)
        filesToProcess = scanned
        statusMessage = "Scanning done: \(scanned.count) files found"
        
        if let first = scanned.first {
            inspectFile(first)
        }
    }
    
    private func inspectFile(_ url: URL) {
        selectedFileURL = url
        isScanningMetadata = true
        inspectorEntries = []
        
        ExifToolWrapper.shared.read(path: url.path) { entries in
            DispatchQueue.main.async {
                self.inspectorEntries = entries ?? []
                self.isScanningMetadata = false
            }
        }
    }
    
    private func startCleaning() {
        guard !filesToProcess.isEmpty else { return }
        isProcessing = true
        progress = 0
        
        let total = Double(filesToProcess.count)
        var completed = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            for file in filesToProcess {
                ExifToolWrapper.shared.process(path: file.path, categories: selectedCategories) { success, msg in
                    DispatchQueue.main.async {
                        completed += 1
                        progress = Double(completed) / total
                        if completed == Int(total) {
                            cleanupAfterProcessing()
                        }
                    }
                }
            }
        }
    }
    
    private func cleanupAfterProcessing() {
        isProcessing = false
        statusMessage = "Success! All files neutralized."
        
        // Refresh inspection for the current file to show it's clean
        if let current = selectedFileURL {
            inspectFile(current)
        }
    }
}

struct DropZoneView: View {
    @Binding var status: String
    var onDrop: ([URL]) -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "shield.righthalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.bottom, 10)
            Text(status)
                .font(.system(size: 16, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
        )
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            var found = false
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            onDrop([url])
                        }
                    }
                }
                found = true
            }
            return found
        }
    }
}

struct ProcessedFilesView: View {
    var files: [URL]
    var onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Detected Files")
                    .font(.headline)
                Spacer()
                Button("Clear", action: onClear)
                    .foregroundColor(.red)
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(files.prefix(5), id: \.self) { file in
                    Text("• \(file.lastPathComponent)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.blue.opacity(0.8))
                }
                if files.count > 5 {
                    Text("... and \(files.count - 5) more.")
                        .italic()
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}
