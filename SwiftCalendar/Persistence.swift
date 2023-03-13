//
//  Persistence.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/12/23.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0 ..< 10 {
            let newDay = Day(context: viewContext)
            newDay.date = Date()
            newDay.didStudy = Bool.random() 
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: "SwiftCalendar")
        if inMemory { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
