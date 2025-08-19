#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

    import Hummingbird
    
    public struct Clown:Decodable, ResponseEncodable, Sendable, Equatable {
        let id: Int
        var name: String
        var spareNoses: Int
    }