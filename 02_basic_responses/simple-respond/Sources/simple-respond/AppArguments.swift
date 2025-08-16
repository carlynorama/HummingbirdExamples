import Hummingbird
import Logging

//Allows for different setups for testing server and production server
public protocol AppArguments {
    var nameTag:String { get }
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
    //TODO: Switch to a MemoryType enum? 
    var inMemoryTesting: Bool { get }
}