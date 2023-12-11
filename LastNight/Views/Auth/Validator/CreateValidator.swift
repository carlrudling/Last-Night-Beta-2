//
//  CreateValidator.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-12.
//

import Foundation

struct CreateValidator {
    
    func validate(_ person: NewPerson) throws {
        
        if person.firstName.isEmpty {
            throw CreateValidatorError.invalidFirstName
        }
        
        if person.lastName.isEmpty {
            throw CreateValidatorError.invalidLastName
        }
        
        if person.email.isEmpty ||  {
            throw CreateValidatorError.invalidEmail
        }
    }
}


extension CreateValidator {
    enum CreateValidatorError: LocalizedError {
        case invalidFirstName
        case invalidLastName
        case invalidEmail
    }
}

extension CreateValidator.CreateValidatorError {
    var errorDescription: String? {
        switch self {
        case .invalidFirstName:
            return "First name can't be empty"
        case .invalidLastName:
            return "Last name can't be empty"
        case .invalidEmail:
            return "Email can't be empty and needs to include a @"
        }
    }
}
