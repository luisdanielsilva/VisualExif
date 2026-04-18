import SwiftUI

struct MetadataInspectorView: View {
    let entries: [MetadataEntry]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Inspector")
                    .font(.system(size: 14, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                Spacer()
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.02))
            
            Divider()
                .opacity(0.1)
            
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(isLoading ? "Scanning..." : "No metadata loaded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(entries) { entry in
                            MetadataRow(entry: entry)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(width: 280)
        .background(Color.black.opacity(0.2))
        .border(width: 1, edges: [.leading], color: Color.white.opacity(0.05))
    }
}

struct MetadataRow: View {
    let entry: MetadataEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.key)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue.opacity(0.8))
            Text(entry.value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.01))
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(
            EdgeBorder(width: width, edges: edges)
                .foregroundColor(color)
        )
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}
