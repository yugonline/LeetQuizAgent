class QuizController < ApplicationController
  # POST /start
  def start
    # Fetch today’s notes from GitHub via the NotesService
    notes_service = NotesService.new
    today = Date.today
    notes = notes_service.fetch_notes_for_date(today)
    notes_content = notes.map { |n| n[:content] }.join("\n")

    # Generate the quiz using your QuizCreationAgent.
    # (Assume that QuizCreationAgent#create_quiz returns a prompt object whose
    #  body holds the quiz questions.)
    agent = QuizCreationAgent.new
    quiz_prompt = agent.create_quiz(notes_content)

    # Extract quiz questions from the prompt.
    # (Here we assume that quiz_prompt.body contains the questions.)
    questions = quiz_prompt.body || "No questions generated; please check your notes."

    # Store the generated quiz in a new QuizSession record.
    quiz_session = QuizSession.create!(
      questions: questions,
      note_content: notes_content,
      status: "active"
    )

    # Return the session id and questions so that /evaluate and /end can use it.
    render json: { session_id: quiz_session.id, questions: questions }
  end

  # POST /evaluate
    def evaluate
      session_id = params[:session_id]
      answers    = params[:answers]

      if session_id.blank? || answers.blank?
        render json: { error: "session_id and answers are required" }, status: :bad_request and return
      end

      quiz_session = QuizSession.find_by(id: session_id)
      unless quiz_session
        render json: { error: "Quiz session not found" }, status: :not_found and return
      end

      # Retrieve the original notes from the QuizSession (stored in note_content).
      notes_content = quiz_session.note_content

      # 1. Evaluate using the new QuizEvaluationAgent
      evaluation_agent  = QuizEvaluationAgent.new
      evaluation_prompt = evaluation_agent.evaluate_quiz(notes_content, answers)
      evaluation_output = evaluation_prompt.body  # The text returned by the agent

      # 2. Update the QuizSession with the evaluation
      quiz_session.update!(
        evaluation: evaluation_output,  # can be a string or JSON, depending on your needs
        status: "evaluated"
      )

      # 3. Send the evaluation results via WhatsApp
      whatsapp_service = WhatsappService.new
      whatsapp_service.send_message("Your quiz results:\n#{evaluation_output}")

      # Return the evaluation back in the JSON response too
      render json: { evaluation: evaluation_output }
    end

  # POST /end
  def end
    # Expect a "session_id" parameter to identify which quiz session to end.
    session_id = params[:session_id]

    unless session_id
      render json: { error: "session_id is required" }, status: :bad_request and return
    end

    quiz_session = QuizSession.find_by(id: session_id)
    unless quiz_session
      render json: { error: "Quiz session not found" }, status: :not_found and return
    end

    # Finalize the quiz session. For example, you might persist any final analysis or cleanup temporary state.
    quiz_session.update!(status: "ended")

    analysis = {
      result: "Quiz ended, results stored",
      session_id: quiz_session.id,
      final_evaluation: quiz_session.evaluation
    }

    render json: analysis
  end
end# frozen_string_literal: true
