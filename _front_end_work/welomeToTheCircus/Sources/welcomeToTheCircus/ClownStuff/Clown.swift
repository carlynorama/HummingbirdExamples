    import Hummingbird
    
    public struct Clown:Decodable, ResponseEncodable, Sendable, Equatable {
        let id: Int
        let name: String
        let spareNoses: Int
    }