import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["answers", "answerButton", "feedback", "correctFeedback", "incorrectFeedback", "cta"]

  selectAnswer(event) {
    // Prevent multiple selections
    if (this.answered) return
    this.answered = true

    const button = event.currentTarget
    const isCorrect = button.dataset.sampleQuizCorrectParam === "true"

    // Disable all buttons
    this.answerButtonTargets.forEach(btn => {
      btn.disabled = true
      btn.classList.remove("hover:border-indigo-300", "hover:bg-indigo-50")
      btn.classList.add("cursor-not-allowed", "opacity-75")
    })

    // Highlight the selected answer
    if (isCorrect) {
      button.classList.remove("border-gray-200", "opacity-75")
      button.classList.add("border-green-500", "bg-green-50", "opacity-100")
    } else {
      button.classList.remove("border-gray-200", "opacity-75")
      button.classList.add("border-red-500", "bg-red-50", "opacity-100")
      
      // Show the correct answer
      this.answerButtonTargets.forEach(btn => {
        if (btn.dataset.sampleQuizCorrectParam === "true") {
          btn.classList.remove("border-gray-200", "opacity-75")
          btn.classList.add("border-green-500", "bg-green-50", "opacity-100")
        }
      })
    }

    // Show feedback
    this.feedbackTarget.classList.remove("hidden")
    if (isCorrect) {
      this.correctFeedbackTarget.classList.remove("hidden")
    } else {
      this.incorrectFeedbackTarget.classList.remove("hidden")
    }

    // Show CTA
    this.ctaTarget.classList.remove("hidden")
  }
}
