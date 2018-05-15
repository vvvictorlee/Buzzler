//
//  SelectMajorViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 15/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol SelectMajorViewModelInputs {
    var major: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol SelectMajorViewModelOutputs {
    var validatedMajor: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var signedUp: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol SelectMajorViewModelType {
    var inputs: SelectMajorViewModelInputs { get }
    var outputs: SelectMajorViewModelOutputs { get }
}

class SelectMajorViewModel: SelectMajorViewModelInputs, SelectMajorViewModelOutputs, SelectMajorViewModelType {
    
    public var validatedMajor: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    
    public var nextTaps: PublishSubject<Void>
    public var major: PublishSubject<String?>
    public var signedUp: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: SelectMajorViewModelInputs { return self }
    public var outputs: SelectMajorViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        self.userInfo = userInfo
        
        self.major = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()

        let validationService = BuzzlerDefaultValidationService.sharedValidationService

        self.validatedMajor = self.major.asDriver(onErrorJustReturn: nil)
            .map { major in
                return validationService.validateTextString(major!)
        }
        
        self.enableNextButton = self.validatedMajor.map { major in
            return major.isValid
        }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        let userInfoDriver = Driver.of(userInfo)
        let userData = Driver.combineLatest(self.major.asDriver(onErrorJustReturn: nil), userInfoDriver) { ($0, $1) }
        
        self.signedUp = self.nextTaps
            .asDriver(onErrorJustReturn: ())
            .withLatestFrom(userData)
            .flatMapLatest { tuple in
                return provider.request(Buzzler.signUp(username: userInfo.nickName!,
                                                       email: userInfo.recevier!,
                                                       password: userInfo.password!,
                                                       categoryAuth: tuple.0!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("signUp res", res)
                        if res is String {
                            return Single.just(true)
                        } else{
                            return Single.just(false)
                        }
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
