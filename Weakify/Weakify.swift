//
//  Weakify.swift
//  RxSwift
//
//  Created by Jeffrey Adler on 10/3/19.
//  Copyright © 2019 Jeffrey Adler. All rights reserved.
//

public func weakifyTarget<ClassType: AnyObject, InputType, OutputType>(
    _ target: ClassType,
    function: @escaping (ClassType) -> (InputType) throws -> OutputType
) -> (InputType) throws -> OutputType {
    let weakExecuter = WeakExecutor<ClassType, InputType, OutputType>(target, function: function)
    return weakExecuter.execute
}


private struct WeakExecutor<ClassType: AnyObject, InputType, OutputType> {
    enum NonRetainError: Error { case weakSelfError }

    weak var target: ClassType?
    let function: (ClassType) -> (InputType) throws -> OutputType

    init(_ target: ClassType, function: @escaping (ClassType) -> (InputType) throws -> OutputType) {
        self.target = target
        self.function = function
    }

    func execute(_ input: InputType) throws -> OutputType {
        guard let target = target else { throw NonRetainError.weakSelfError }
        return try function(target)(input)
    }
}