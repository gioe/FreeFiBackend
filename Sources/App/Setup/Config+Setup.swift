import FluentProvider
import SwiftyBeaverProvider
import MySQLProvider
import PostgreSQLProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(SwiftyBeaverProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Spot.self)
        preparations.append(Network.self)
        preparations.append(Pivot<Spot, Network>.self)
    }
    
}
