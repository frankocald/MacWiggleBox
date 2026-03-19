import SwiftUI
import UniformTypeIdentifiers

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
    
    var body: some View {
        VStack {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                .resizable()
                .frame(width: 48, height: 48)
            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 80)
        }
        .padding(8)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
