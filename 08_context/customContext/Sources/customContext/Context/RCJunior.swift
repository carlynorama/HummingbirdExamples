import Hummingbird


struct RCJunior: ChildRequestContext {
    var coreContext: CoreRequestContextStorage
    let magicNumber: Int

    //expects concrete type. 
    init(context parentContext: MyForwardingContext) throws {
        self.coreContext = parentContext.coreContext
        guard parentContext.timeConsumingData != nil else {
            //https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/418
            throw HTTPError.init(.init(code: 418, reasonPhrase: "I am a teapot."))
        }
        self.magicNumber = parentContext.timeConsumingData!
    }
}