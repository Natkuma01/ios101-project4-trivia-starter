//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import Foundation

struct TriviaQuestion {
  let category: String
  let question: String
  let correctAnswer: String
  let incorrectAnswers: [String]
}

struct QuestionResult: Decodable {
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

struct TriviaAPIResponse: Decodable {
    let responseCode: Int
    let results: [QuestionResult]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}
