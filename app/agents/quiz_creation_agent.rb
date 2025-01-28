# app/agents/quiz_creation_agent.rb

class QuizCreationAgent < ActiveAgent::Base
  # Configure your OpenAI provider settings here. The library will use these
  # credentials (like API key, default model, temperature, etc.) when it
  # actually calls OpenAI.

  # In the simplest usage, you can just do:
  generate_with :openai, model: "gpt-4o", temperature: 0.7

  # If you have custom streaming logic you can do:
  # stream_with do |chunk|
  #   # ...
  # end

  # The "action" we want is `create_quiz`.
  # Here is where we define how we build the prompt.
  def create_quiz(notes_content)
    # We can set up instructions or pass the “notes_content” into the prompt.
    # Usually, you'd also store it in an instance variable if you want to
    # reference it in ERB templates: e.g. `@notes_content = notes_content`.
    # But for a simple one-off prompt, we can inline everything here.

    prompt(
      instructions: "You are a Quiz Master.",
      context: [
        { role: "system", content: "You are a Quiz Master." },
        # or you can store user’s notes in the prompt body, or as a separate message.
      ],
      body: <<~USER_PROMPT
        Create a quiz (in under 1000 characters, just theory no coding questions) from:

        #{notes_content}
      USER_PROMPT
    )
  end
end