    import Hummingbird
    
    public struct Clown:Decodable, ResponseEncodable, Sendable {
        let id: Int
        let name: String
        let spareNoses: Int
    }