//
//  SignUpViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-12.
//

import Foundation
import SwiftUI

final class SignUpViewModel: ObservableObject {
    
  // Input values from View
  @Published var firstName = ""
  @Published var lastName = ""
  @Published var userName = ""
  @Published var userEmail = ""
  @Published var password = ""
  @Published var userRepeatedPassword = ""
  
  // Output subscribers
  @Published var formIsValid = false
  
  private var publishers = Set<AnyCancellable>()
  
  init() {
    isSignupFormValidPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.formIsValid, on: self)
      .store(in: &publishers)
  }
}

// MARK: - Setup validations
private extension SignUpViewModel {
    
  var isUserNameValidPublisher: AnyPublisher<Bool, Never> {
    $userName
      .map { name in
          return name.count >= 5
      }
      .eraseToAnyPublisher()
  }
  
  var isUserEmailValidPublisher: AnyPublisher<Bool, Never> {
    $userEmail
      .map { email in
          let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
          return emailPredicate.evaluate(with: email)
      }
      .eraseToAnyPublisher()
  }
  
  var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
    $userPassword
      .map { password in
          return password.count >= 8
      }
      .eraseToAnyPublisher()
  }
  
  
  var passwordMatchesPublisher: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest($userPassword, $userRepeatedPassword)
      .map { password, repeated in
          return password == repeated
      }
      .eraseToAnyPublisher()
  }
  
  var isSignupFormValidPublisher: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest4(
      isUserNameValidPublisher,
      isUserEmailValidPublisher,
      isPasswordValidPublisher,
      passwordMatchesPublisher)
      .map { isNameValid, isEmailValid, isPasswordValid, passwordMatches in
          return isNameValid && isEmailValid && isPasswordValid && passwordMatches
      }
      .eraseToAnyPublisher()
  }
}
