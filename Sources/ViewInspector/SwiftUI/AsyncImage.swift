import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct AsyncImage: KnownViewType {
        public static var typePrefix: String = "AsyncImage"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func asyncImage() throws -> InspectableView<ViewType.AsyncImage> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func asyncImage(_ index: Int) throws -> InspectableView<ViewType.AsyncImage> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.AsyncImage: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return .empty }
        return .init(count: 3) { index in
            switch index {
            case 0:
                return try view(for: .empty, parent: parent)
            case 1:
                return try view(for: .failure(InspectionError.notSupported("")), parent: parent)
            default:
                return try view(for: .success(Image("ViewInspector")), parent: parent)
            }
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    fileprivate static func view(for phase: AsyncImagePhase, parent: UnwrappedView
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        let provider = try Inspector.cast(value: parent.content.view, type: ElementViewProvider.self)
        let view = try provider.view(phase)
        let medium = parent.content.medium.resettingViewModifiers()
        let content = try Inspector.unwrap(content: Content(view, medium: medium))
        return try InspectableView<ViewType.ClassifiedView>(
            content, parent: parent, call: phase.contentInspectionCall)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
internal extension AsyncImagePhase {
    var contentInspectionCall: String {
        switch self {
        case .empty: return "contentView(.empty)"
        case .failure: return "contentView(.failure())"
        case .success: return "contentView(.success())"
        @unknown default: return "contentView(.\(String(describing: self)))"
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.AsyncImage {
    
    func url() throws -> URL? {
        return try Inspector.attribute(
            label: "url", value: content.view, type: URL?.self)
    }
    
    func scale() throws -> CGFloat {
        return try Inspector.attribute(
            label: "scale", value: content.view, type: CGFloat.self)
    }
    
    func transaction() throws -> Transaction {
        return try Inspector.attribute(
            label: "transaction", value: content.view, type: Transaction.self)
    }
    
    func contentView(_ phase: AsyncImagePhase) throws -> InspectableView<ViewType.ClassifiedView> {
        return try ViewType.AsyncImage.view(for: phase, parent: self)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AsyncImage: ElementViewProvider {
    func view(_ element: Any) throws -> Any {
        let phase = try Inspector.cast(value: element, type: AsyncImagePhase.self)
        typealias Provider = (AsyncImagePhase) -> Content
        let provider = try Inspector.attribute(label: "content", value: self, type: Provider.self)
        return provider(phase)
    }
}
