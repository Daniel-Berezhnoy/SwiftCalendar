//
//  Persistence.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/12/23.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    let databaseName = "SwiftCalendar.sqlite"
    
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appending(component: databaseName)
//        .applicationSupportDirectory.appending(path: databaseName)
    }
    
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.daniel.SwiftCalendar")!
        return container.appending(component: databaseName)
    }

    static var preview: PersistenceController = {
        
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let startDate = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
        
        for dayOffset in 0 ..< 30 {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)
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
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func migrateStore(for container: NSPersistentContainer) {
        
        print("🚪 Entered the function")
        
        // Creating a Store Coordinator
        let coordinator = container.persistentStoreCoordinator
        
        // Checking that the Old Store has data in it
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        
        print("🔍 Old Store data found")
        
        // Making the actual migration from the Old Store -> NEW Shared Store
        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
            print("🏁 Migration successful")
        } catch {
            fatalError("Unable to migrate to Shared Store. \n\(error.localizedDescription)")
        }
        
        // Cleaning up the data from the Old Store
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
            print("🗑️ Old Store Deleted")
        } catch {
            print("Unable to delete Old Store. \n\(error.localizedDescription)")
        }
    }
}
