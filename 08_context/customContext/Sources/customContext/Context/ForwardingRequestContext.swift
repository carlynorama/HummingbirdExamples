import Hummingbird

protocol ForwardingRequestContext: RequestContext {
  var noteToPass: String? { get set }
  var timeConsumingData: Int? { get set }
}

public struct MyForwardingContext: ForwardingRequestContext {
  public var coreContext: CoreRequestContextStorage

  public var noteToPass: String?
  public var timeConsumingData: Int?

  public init(source: Source) {
    self.coreContext = .init(source: source)
    self.noteToPass = nil
    self.timeConsumingData = nil
  }
}
