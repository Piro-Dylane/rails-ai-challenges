class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Teaching Assistant.\n\nI am a student at the Le Wagon Web Development Bootcamp, learning how to code.\n\nHelp me break down my problem into small, actionable steps, without giving away solutions.\n\nAnswer concisely in markdown."
  def index
    @challenge = Challenge.find(params[:challenge_id])
  end

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new(role: "user", content: params[:message][:content], challenge: @challenge)
    if @message.save!
      # Instancie un nouveau chat
      @chat = RubyLLM.chat
      # Je récupère la réponse du LLM dans response par rapport au message de l'utilisateur et par rapport au Prompt
      response = @chat.with_instructions(instructions).ask(@message.content)
      # Je crée un message de la réponse du LLM
      Message.create!(role: "assistant", content: response.content, challenge: @challenge)
      # Si c'est bon je redirige sur l'index des messages
      redirect_to challenge_messages_path(@challenge)
    else
      render :new
    end
  end


  private

  def challenge_context
    "Here is the context of the challenge: #{@challenge.content}"
  end

  def instructions
    # Je viens récupérer le SYSTEM_PROMPT et challenge_context et je les mets dans un array.
    [SYSTEM_PROMPT, challenge_context, @challenge.system_prompt].compact.join("\n\n")
  end
end
