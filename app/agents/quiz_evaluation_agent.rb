class QuizEvaluationAgent < ActiveAgent::Base
  # Adjust the model and parameters as you see fit:
  generate_with :openai, model: "gpt-4o", temperature: 0.7


  # Define an action that evaluates quiz answers based on the original notes.
  def evaluate_quiz(notes_content, user_answers)
    prompt(
      instructions: "You are an expert educator who evaluates student answers based on the provided notes.",
      context: [
        { role: "system", content: "You have access to the notes and the user's answers. Provide a short but clear evaluation." }
      ],
      body: <<~PROMPT
        NOTES CONTENT:
        #{notes_content}

        USER’S ANSWERS:
        #{user_answers}

        Please provide a quick evaluation of the accuracy and completeness of these answers, plus a short explanation and a numerical score out of 10.
      PROMPT
    )
  end
end
