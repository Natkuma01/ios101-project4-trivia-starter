// TriviaQuestionService.swift
import Foundation

class TriviaQuestionService {

    // This struct will represent a single question object from the 'results' array in the API response.
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

    // This struct will represent the overall API response, which contains a "results" array of questions.
    struct TriviaAPIResponse: Decodable {
        let responseCode: Int
        let results: [QuestionResult]

        enum CodingKeys: String, CodingKey {
            case responseCode = "response_code"
            case results
        }
    }

    // Function to fetch trivia questions
    static func fetchQuestions(completion: (([TriviaQuestion]?) -> Void)? = nil) {
        let urlString = "https://opentdb.com/api.php?amount=10&category=11&difficulty=easy&type=multiple"

        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion?(nil) // Call completion with nil on error
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { // Ensure completion is called on main thread
                    completion?(nil)
                }
                return
            }

            guard let data = data else {
                print("No data received from API.")
                DispatchQueue.main.async { // Ensure completion is called on main thread
                    completion?(nil)
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(TriviaAPIResponse.self, from: data)

                if apiResponse.responseCode != 0 {
                    print("API Error Code: \(apiResponse.responseCode)")
                    DispatchQueue.main.async { // Ensure completion is called on main thread
                        completion?(nil)
                    }
                    return
                }

                // Convert QuestionResult array to TriviaQuestion array, decoding HTML entities
                let triviaQuestions = apiResponse.results.map { result in
                    TriviaQuestion(category: result.category,
                                   question: result.question.htmlDecoded,
                                   correctAnswer: result.correctAnswer.htmlDecoded,
                                   incorrectAnswers: result.incorrectAnswers.map { $0.htmlDecoded })
                }
                
                // Call the completion handler on the main thread
                DispatchQueue.main.async {
                    completion?(triviaQuestions)
                }

            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async { // Ensure completion is called on main thread
                    completion?(nil)
                }
            }
        }
        task.resume() // Start the network request
    }
}

// Extension to decode HTML entities in strings
extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}
