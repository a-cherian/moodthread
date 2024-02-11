//
//  DataManager.swift
//  Moodthread
//
//  Created by AC on 11/2/23.
//

import CoreData

struct DataManager {
    
    static let shared = DataManager()
    
    let persistentContainer: NSPersistentContainer = {
        ValueTransformer.setValueTransformer(FieldDataTransformer(), forName: .fieldToDataTransformer)
        let container = NSPersistentContainer(name: "Moodthread")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    @discardableResult
    func createEntry(time: Date, fields: [Field]) -> Entry? {
        let context = persistentContainer.viewContext
        
        let entry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context) as! Entry
        
        entry.time = time
        entry.fields = fields
        
        do {
            try context.save()
            return entry
        } catch let createError {
            print("Failed to create: \(createError)")
        }
        
        return nil
    }
    
    func fetchEntries() -> [Entry]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Entry>(entityName: "Entry")
        
        do {
            let entries = try context.fetch(fetchRequest)
            return entries
        } catch let fetchError {
            print("Failed to fetch: \(fetchError)")
        }
        
        return nil
    }
    
    func updateEntry(entry: Entry) {
        let context = persistentContainer.viewContext
        print(context.updatedObjects)
        
        do {
            try context.save()
        } catch let createError {
            print("Failed to update: \(createError)")
        }
    }
    
    func deleteEntry(entry: Entry) {
        let context = persistentContainer.viewContext
        context.delete(entry)
        
        do {
            try context.save()
        } catch let saveError {
            print("Failed to update: \(saveError)")
        }
    }
    
    func deleteAllEntries() {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Entry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let saveError {
            print("Failed to update: \(saveError)")
        }
    }
    
    func getCustomFields() -> [ItemConfiguration] {
        let userDefaults = UserDefaults.standard
        if let customConfigs = userDefaults.array(forKey: Constants.CUSTOM_FIELDS_KEY) as? [[String]] {
            let unpacked = customConfigs.compactMap { ItemConfiguration.unstringify(string: $0) }
            return unpacked
        }
        return []
    }
}
