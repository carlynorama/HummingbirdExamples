import Hummingbird

protocol ForwardingRequestContext: RequestContext {
    var timeConsumingData: Int? { get set }
    var noteToPass: String?  { get set }
}

public struct MyForwardingContext: ForwardingRequestContext {
    public var coreContext: CoreRequestContextStorage
    public var timeConsumingData: Int?
    public var noteToPass: String?

    public init(source: Source) {
        self.coreContext = .init(source: source)
        self.timeConsumingData = nil
        self.noteToPass = nil
    }
}