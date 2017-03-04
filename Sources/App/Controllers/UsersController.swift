//
//  UsersController.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 04/03/2017.
//
//

import Vapor
import VaporPostgreSQL
import HTTP
import Foundation

final class UsersController {
	
	func addRoutes(drop: Droplet) {
		let users = drop.grouped(User.entity)
		
		users.post(handler: register)
	}
	
	/// Register a new user
	func register(for request: Request) throws -> ResponseRepresentable {
		
		// Validate name and email input
		let name: Valid<OnlyAlphanumeric> = try request.data[Identifiers.name].validated()
		let email: Valid<Email> = try request.data[Identifiers.email].validated()
		
		// Get password as a string
		guard let password = request.data[Identifiers.password]?.string else {
			throw Abort.custom(status: .badRequest, message: "Missing required \(Identifiers.password) value")
		}

		var user = User(name: name.value, email: email.value, password: password)
		try user.save()
	
		// Return JSON for newly created user or redirect to HTML page (GET /lists)
		if request.headers[HeaderKey.contentType] == Identifiers.json {
			return try user.makeJSON()
		} else {
			return Response(redirect: "/")
		}
	}

}
