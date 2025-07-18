//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0

  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
      
      let firstQuest = TriviaQuestion(category: "Testing", question:"Testing", correctAnswer: "Testing", incorrectAnswers: ["Testing1", "Testing2", "Testing3"])
      let secondQuest = TriviaQuestion(category: "Testing", question:"Testing", correctAnswer: "Testing", incorrectAnswers: ["Testing1", "Testing2", "Testing3"])
      questions = [firstQuest, secondQuest]
      
    questionContainerView.layer.cornerRadius = 8.0
    fetchTriviaQuestions()
    // TODO: FETCH TRIVIA QUESTIONS HERE
  }
    
    private func fetchTriviaQuestions() {
        questions.removeAll()
        currQuestionIndex = 0
        numCorrectQuestions = 0
        
        TriviaQuestionService.fetchQuestions { [weak self] fetchedQuestions in
                 // Ensure self exists and we're on the main thread for UI updates
                 guard let self = self else { return }

                 // Check if questions were successfully fetched
                 if let fetchedQuestions = fetchedQuestions, !fetchedQuestions.isEmpty {
                     self.questions = fetchedQuestions
                     // Update the UI with the first question
                     self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
                 } else {
                     // Handle case where no questions were fetched
                     print("Failed to load questions or no questions available.")
                     self.questionLabel.text = "Failed to load questions. Restart to try again."
                     self.categoryLabel.text = ""
                 }
             }
    }

  
  private func updateQuestion(withQuestionIndex questionIndex: Int) {
    currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
    let question = questions[questionIndex]
    questionLabel.text = question.question
    categoryLabel.text = question.category
    let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
    if answers.count > 0 {
      answerButton0.setTitle(answers[0], for: .normal)
    }
    if answers.count > 1 {
      answerButton1.setTitle(answers[1], for: .normal)
      answerButton1.isHidden = false
    }
    if answers.count > 2 {
      answerButton2.setTitle(answers[2], for: .normal)
      answerButton2.isHidden = false
    }
    if answers.count > 3 {
      answerButton3.setTitle(answers[3], for: .normal)
      answerButton3.isHidden = false
    }
  }
  
   // Helper function for FEATURE5
    private func proceedToNextQuestionOrEnd() {
        if currQuestionIndex < questions.count {
            updateQuestion(withQuestionIndex: currQuestionIndex)
        } else {
            showFinalScore()
        }
    }
    
  private func updateToNextQuestion(answer: String) {
      // FEATURE5: Provide user feedback on incorrect questions
    let correct = isCorrectAnswer(answer)
    if correct {
      numCorrectQuestions += 1
        currQuestionIndex += 1
        proceedToNextQuestionOrEnd()
    } else {
        let correctAnswer = questions[currQuestionIndex].correctAnswer
        let alert = UIAlertController(title: "Incorrect!", message: "The correct answer was \(correctAnswer)", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Next", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currQuestionIndex += 1
            self.proceedToNextQuestionOrEnd()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
  }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
      currQuestionIndex = 0
      numCorrectQuestions = 0
      updateQuestion(withQuestionIndex: currQuestionIndex)
        self.fetchTriviaQuestions()     // try to refetch new questins again
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
    
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
}

