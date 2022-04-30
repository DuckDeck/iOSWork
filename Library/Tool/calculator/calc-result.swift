//
//  calc-result.swift
//  calc
//
//  Created by Josh Smith.
//  Copyright © 2019 iJoshSmith. All rights reserved.
//

/// The outcome of performing a step in the calculation pipeline.
enum CalcResult<Value: Equatable>: Equatable {

    case value(Value)
    case error(CalcError)

    func then<NextValue>(_ produceNextResult: (Value) -> CalcResult<NextValue>) -> CalcResult<NextValue> {
        switch self {
        case .value(let value): return produceNextResult(value)
        case .error(let error): return .error(error)
        }
    }
    
  
    
}

func calculate(_ input: String) -> CalcResult<Number> {
    return InputParser.createGlyphs(from: input)
        .then(Tokenizer.createTokens(fromGlyphs:))
        .then(Operationizer.createOperations(fromTokens:))
        .then(Expressionizer.createExpression(fromOperations:))
        .then(Calculator.evaluate(expression:))
}


//func getCalIndex(_ input: String) -> Int{
//    
//}
