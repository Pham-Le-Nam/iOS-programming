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
        // Calculate * / % from left to right
        let afterHigh = try applyHighPrecedence(args: args)
        // Calculate + - from left to right
        let afterLow = try applyLowPrecedence(args: afterHigh)
        // Convert result to int to remove its + sign if exists
        guard let result = Int(afterLow[0]) else {
            throw CalcError.invalidInput("Result cannot be converted to Int")
        }
        return result
    }
    
    // Calculate all * / %
    private func applyHighPrecedence(args: [String]) throws -> [String] {
        // Last operand in the calculation
        if (args.count == 1) {
            return args;
        }

        // 1 operand and 1 operator couldn't be calculated
        guard args.count >= 3 else {
            throw CalcError.invalidInput("Invalid input amount");
        }

        // Get and convert first operand into an Integer
        guard let firstNumber = Int(args[0]) else {
            throw CalcError.invalidInput("Expected a number");
        }

        // Operator
        let op = args[1];

        // Check if operator is a high precedence
        if (op == "x" || op == "/" || op == "%") {
            // Get and convert second operand into an integer
            guard let secondNumber = Int(args[2]) else {
                throw CalcError.invalidInput("Expected a number");
            }

            var subResult: Int = 0;
            
            // Multiplication
            if (op == "x") {
                // Check integer overflow
                let (calculationResult, didOverflow) = firstNumber.multipliedReportingOverflow(by: secondNumber)
                guard !didOverflow else {
                    throw CalcError.integerOverflow;
                }
                subResult = calculationResult;
            }
            // Division
            else if (op == "/"){
                // Division by zero error
                if (secondNumber == 0) {
                    throw CalcError.divisionByZero;
                }
                subResult = firstNumber / secondNumber;
            }
            // Modulo
            else {
                subResult = firstNumber % secondNumber;
            }
            
            // Replace the calculated elements with the subResult
            let newArgs = [String(subResult)] + args.dropFirst(3);
            // Recursion until all of the high precedent operator is calculated.
            return try applyHighPrecedence(args: newArgs);
        }
        // Skip 2 first elements
        else if (op == "+" || op == "-") {
            // Calculate if there are high precedence operator after this
            let newArgs = try ([args[0], args[1]] + applyHighPrecedence(args: Array(args.dropFirst(2))));
            return newArgs;
        }
        
        throw CalcError.invalidInput("Invalid operand");
    }
    
    // Calculate all + -
    private func applyLowPrecedence(args: [String]) throws -> [String] {
        // Last operand in the calculation
        if (args.count == 1) {
            return args;
        }

        // 1 operand and 1 operator couldn't be calculated
        guard args.count >= 3 else {
            throw CalcError.invalidInput("Invalid input amount");
        }

        // Get and convert first operand into an Integer
        guard let firstNumber = Int(args[0]) else {
            throw CalcError.invalidInput("Expected a number");
        }

        // Operator
        let op = args[1];
        
        // Invalid operator
        guard op == "+" || op == "-" else {
            throw CalcError.invalidInput("Invalid operator")
        }

        guard let secondNumber = Int(args[2]) else {
            throw CalcError.invalidInput("Expected a number");
        }

        var subResult: Int = 0;
        
        // Addition
        if (op == "+") {
            // Check integer overflow
            let (result, didOverflow) = firstNumber.addingReportingOverflow(secondNumber)
            guard !didOverflow else {
                throw CalcError.integerOverflow
            }
            subResult = result
        }
        // Subtraction
        else {
            subResult = firstNumber - secondNumber;
        }
        
        // Replace the calculated elements with the subResult
        let newArgs = [String(subResult)] + args.dropFirst(3);
        // Recursion until all of the low precedent operator is calculated.
        return try applyLowPrecedence(args: newArgs);
    }
}

