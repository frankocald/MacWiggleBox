import Foundation

public class ShelfViewModel: ObservableObject {
    @Published public var files: [URL] = []
    
    public init() {}
    
    public func addFile(_ url: URL) {
        if !files.contains(url) {
            files.append(url)
        }
    }
    
    public func removeFile(_ url: URL) {
        files.removeAll { $0 == url }
    }
    
    public func clear() {
        files.removeAll()
    }
}
