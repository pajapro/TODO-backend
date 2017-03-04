//
//  User.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 04/03/2017.
//
//

import Foundation
import Vapor
import Fluent
import Turnstile
import TurnstileCrypto

/// Struct holding information about a user
public struct User: Model {
	
	// MARK: - Properties
	
	/// User entity name
	fileprivate let entity = "users"
	
	/// Contains the identifier when the model is fetched from the database. If it is `nil`, it **will be set when the model is saved**.
	public var id: Node?
	
	/// User name
	public var name: String
	
	/// User email
	public var email: String
	
	/// User password
	public var password: String
	
	// MARK: - Initializers
	
	public init(name: String, email: String, rawPassword: String) {
		self.id = nil
		self.name = name
		self.email = email
		self.password = BCrypt.hash(password: rawPassword)	// hash given password
	}
}

// MARK: - NodeInitializable protocol (how to initialize our model FROM the database)

extension User: NodeInitializable {
	
	/// Initializer creating model object from Node (Fluent pulls data from DB into intermediate representation `Node` THEN we need to convert back to type-safe model)
	public init(node: Node, in context: Context) throws {
		self.id = try node.extract(Identifiers.id)
		self.name = try node.extract(Identifiers.name)
		self.email = try node.extract(Identifiers.email)
		self.password = try node.extract(Identifiers.password)
	}
}

// MARK: - NodeRepresentable protocol (how to save our model TO the database)

extension User: NodeRepresentable {
	
	/// Converts type-safe model into an instance of `Node` object
	public func makeNode(context: Context) throws -> Node {
		let node = try Node(node: [
			Identifiers.id: self.id,
			Identifiers.name: self.name,
			Identifiers.email: self.email,
			Identifiers.password: self.password,
		])
		
		return node
	}
}

// MARK: - Preparation protocol

extension User: Preparation {
	
	/// The prepare method should call any methods it needs on the database to prepare.
	public static func prepare(_ database: Database) throws {
		try database.create(self.entity) { users in
			users.id()
			users.string(Identifiers.name)
			users.string(Identifiers.email)
			users.string(Identifiers.password)
		}
	}
	
	/// The revert method should undo any actions caused by the prepare method.
	public static func revert(_ database: Database) throws {
		try database.delete(self.entity)	// only called when manually executed via CLI
	}
}

