# app/services/whatsapp_service.rb
require 'twilio-ruby'

class WhatsappService
  def initialize
    @account_sid = ENV['TWILIO_ACCOUNT_SID']
    @auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
    @from = "whatsapp:#{ENV['TWILIO_WHATSAPP_FROM']}"
    @to   = "whatsapp:#{ENV['TWILIO_WHATSAPP_TO']}"
  end

  def send_message(body)
    @client.messages.create(
      from: @from,
      to:   @to,
      body: body
    )
  end
end