import SwiftUI
import UniformTypeIdentifiers
import QuickLookThumbnailing

public struct ShelfView: View {
    @ObservedObject var viewModel: ShelfViewModel
    
    public init(viewModel: ShelfViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack {
                if viewModel.files.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("Drop files here")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.files, id: \.self) { url in
                                FileItemView(url: url)
                                    .onDrag {
                                        NSItemProvider(object: url as NSURL)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .frame(minWidth: 200, minHeight: 150)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            viewModel.addFile(url)
                        }
                    }
                }
            }
            return true
        }
    }
}

struct FileItemView: View {
    let url: URL
    @State private var thumbnail: NSImage?
    
    var body: some View {
        VStack {
            if let image = thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            } else {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            
            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 80)
        }
        .padding(8)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            await generateThumbnail()
        }
    }
    
    @MainActor
    private func generateThumbnail() async {
        let size = CGSize(width: 128, height: 128)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: NSScreen.main?.backingScaleFactor ?? 2.0, representationTypes: .thumbnail)
        
        do {
            let result = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            self.thumbnail = result.nsImage
        } catch {
            // Silently fallback to system icon (already handled in body)
        }
    }
}

// Helper for blur effect
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
