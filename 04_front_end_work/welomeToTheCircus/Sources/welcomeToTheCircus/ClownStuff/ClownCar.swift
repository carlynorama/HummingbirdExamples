import Hummingbird

//TODO: encoding fails on actor, as does RawRepresentable
actor ClownCar {
    var seats:[Clown]

    init() {
        seats = [
            Clown(id: 0, name:"Pagliacci" , spareNoses: 0),
            Clown(id: 1, name:"Joseph Grimaldi" , spareNoses: 12),
            Clown(id: 4, name:"Weary Willie" , spareNoses: 1),
            //Clown(id: 224111, name:"Bozo" , spareNoses: 4141),
        ]
    }

    /// Get clown
    func get(id: Int) async throws -> Clown? {
        return self.seats.first { $0.id == id }
    }
    /// List all clowns
    func list() async throws -> [Clown] {
        return self.seats.map { $0 }
    }
}