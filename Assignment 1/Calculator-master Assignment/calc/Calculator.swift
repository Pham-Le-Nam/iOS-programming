//
//  Calculator.swift
//  calc
//
//  Created by Jacktator on 31/3/20.
//  Copyright © 2020 UTS. All rights reserved.
//

import Foundation

class Calculator {
    enum CalcError: Error, CustomStringConvertible {
        case invalidInput(String)
        case divisionByZero
        case integerOverflow
        
        var description: String {
            switch self {
            case .invalidInput(let msg): return "Invalid input: \(msg)"
            case .divisionByZero: return "Division by zero"
            case .integerOverflow: return "Integer overflow"
            }
        }
    }
    
    func calculate(args: [String]) throws -> Int { // returns Int
        let afterHigh = try applyHighPrecedence(args: args)
        let afterLow = try applyLowPrecedence(args: afterHigh)
        // Convert result to int to remove its sign
        guard let result = Int(afterLow[0]) else {
            throw CalcError.invalidInput("Result cannot be converted to Int")
        }
        return result
    }
    
    // Calculate all */%
    private func applyHighPrecedence(args: [String]) throws -> [String] {
        if (args.count == 1) {
            return args;
        }

        guard args.count >= 3 else {
            throw CalcError.invalidInput("Invalid input amount");
        }

        guard let number = Int(args[0]) else {
            throw CalcError.invalidInput("Expected a number");
        }

        let op = args[1];

        if (op == "x" || op == "/" || op == "%") {
            guard let secondNumber = Int(args[2]) else {
                throw CalcError.invalidInput("Expected a number");
            }

            var subResult: Int = 0;
            
            if (op == "x") {
                guard subResult = number * secondNumber else {
                    throw CalcError.integerOverflow;
                };
            }
            else if (op == "/"){
                if (secondNumber == 0) {
                    throw CalcError.divisionByZero;
                }
                subResult = number / secondNumber;
            }
            else {
                subResult = number % secondNumber;
            }
            
            // Remove the calculated elements
            let newArgs = [String(subResult)] + args.dropFirst(3);
            // Add the subResult;
            return try applyHighPrecedence(args: newArgs);
        }
        else if (op == "+" || op == "-") {
            // Calculate if there are high precedence operator after this
            let newArgs = try ([args[0], args[1]] + applyHighPrecedence(args: Array(args.dropFirst(2))));
            return newArgs;
        }
        
        throw CalcError.invalidInput("Invalid operand");
    }
    
    // Calculate all +-
    private func applyLowPrecedence(args: [String]) throws -> [String] {
        if (args.count == 1) {
            return args;
        }

        guard args.count >= 3 else {
            throw CalcError.invalidInput("Invalid input amount");
        }

        guard let number = Int(args[0]) else {
            throw CalcError.invalidInput("Expected a number");
        }

        let op = args[1];

        if (op == "+" || op == "-") {
            guard let secondNumber = Int(args[2]) else {
                throw CalcError.invalidInput("Expected a number");
            }

            var subResult: Int = 0;
            
            if (op == "+") {
                subResult = number + secondNumber;
            }
            else {
                subResult = number - secondNumber;
            }
            
            // Remove the calculated elements
            var newArgs = [String(subResult)] + args.dropFirst(3);
            // Add the subResult;
            return try applyLowPrecedence(args: newArgs);
        }
        
        throw CalcError.invalidInput("Invalid operand");
    }
}

