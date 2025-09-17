
actor ClownCar {
  var clowns: [Int: Clown]

  init() {
    clowns = [
      0: Clown(id: 0, name: "Pagliacci", spareNoses: 0),
      1: Clown(id: 1, name: "Joseph Grimaldi", spareNoses: 41417),
      4: Clown(id: 4, name: "Weary Willie", spareNoses: 1),
      //Clown(id: 224111, name:"Bozo" , spareNoses: 4141),
    ]
  }

  // CREATE

  /// create a clown.
  func create(name: String, spareNoses: Int = 10) async throws -> Clown {
    let id = Int.random(in: 1000..<10000)
    let clown = Clown(id: id, name: name, spareNoses: spareNoses)
    self.clowns[id] = clown
    return clown
  }

  // READ

  /// Get clown
  func get(id: Int) async throws -> Clown? {
    return self.clowns[id]
  }
  /// List all clowns
  func list() async throws -> [Clown] {
    return self.clowns.values.map { $0 }
  }

  //UPDATE

  /// Update clown. Returns updated clown if successful
  func update(id: Int, name: String?, spareNoses: Int?) async throws -> Clown? {
    if var clown = self.clowns[id] {
      if let name {
        clown.name = name
      }
      if let spareNoses {
        clown.spareNoses = spareNoses
      }
      self.clowns[id] = clown
      return clown
    }
    return nil
  }

  //DELETE

  /// Delete clown. Returns true if successful
  func delete(id: Int) async throws -> Bool {
    if self.clowns[id] != nil {
      self.clowns[id] = nil
      return true
    }
    return false
  }
  /// Delete all clowns
  func deleteAll() async throws {
    self.clowns = [:]
  }

}
