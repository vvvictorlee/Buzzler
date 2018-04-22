//
//  LoginViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class LoginViewModel {
    
    // Input
    var email = Variable("")
    var password = Variable("")
    var loginTaps = PublishSubject<Void>()
    
    // Output
    let loginEnabled: Driver<Bool>
    let loginFinished: Driver<LoginResult>
    let loginExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        loginExecuting = Variable(false).asDriver().distinctUntilChanged()
        
        let emailObservable = email.asObservable()
        let passwordObservable = password.asObservable()
        
        loginEnabled = Observable.combineLatest(emailObservable, passwordObservable) { $0.characters.count > 3 && $1.characters.count > 3 }
            .asDriver(onErrorJustReturn: false)
        
        let emailAndPassword = Observable.combineLatest(emailObservable, passwordObservable){ ($0, $1) }
      
        loginFinished = loginTaps
            .asObservable()
            .withLatestFrom(emailAndPassword)
            .do(onNext: { json in
                // var appToken = Token()
                //                appToken.token = json["token"] as? String
                print(json)
            })
            .map { json in
                //                if let message = json["message"] as? String {
                //                    return LoginResult.failed(message: message)
                //                } else {
                //                    return LoginResult.ok
                //                }
                return LoginResult.ok
            }
            .asDriver(onErrorJustReturn: LoginResult.failed(message: "Oops, something went wrong")).debug()
    }
    
  
}