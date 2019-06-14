//
//  AwesomeRealmCache.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison Hoffmann on 4/28/18.
//

import RealmSwift
import Realm

public class AwesomeRealmCache: Object {
    @objc dynamic public var key: String = ""
    @objc dynamic public var value: Data? = nil
    
    public static var databaseSchemaVersion: UInt64 {
        set {
            UserDefaults.standard.set(newValue, forKey: "databaseSchemaVersion")
        }
        get {
            return UInt64(UserDefaults.standard.integer(forKey: "databaseSchemaVersion"))
        }
    }
    
    // MARK: - Realm configuration and migration
    
    static func configureRealmDatabase() {
        let config = Realm.Configuration(
            schemaVersion: databaseSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                print("Successfully migrated Realm database from \(oldSchemaVersion) to \(databaseSchemaVersion)")
        })
        Realm.Configuration.defaultConfiguration = config
        print("Realm database location: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
    }
    
    static func clearDatabase() {
        let realm = try? Realm()
        try? realm?.write {
            realm?.deleteAll()
        }
    }
    
    // MARK: - Realm
    
    override public static func primaryKey() -> String? {
        return "key"
    }
    
    init(key: String, value: Data) {
        super.init()
        
        self.key = key
        self.value = value
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    func save() {
        let realm = try? Realm()
        try? realm?.write {
            realm?.add(self, update: true)
        }
    }
    
    static func object(forKey key: String) -> AwesomeRealmCache? {
        let realm = try? Realm()
        return realm?.object(ofType: AwesomeRealmCache.self, forPrimaryKey: key)
    }
    
    static func data(forKey key: String) -> Data? {
        return object(forKey: key)?.value
    }
}
