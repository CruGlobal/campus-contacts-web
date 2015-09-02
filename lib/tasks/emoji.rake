require 'emojimmy'
namespace :emoji do
  task :convert_to_token => :environment do
    ReceivedSms.find_each do |received_sms|
      received_sms.update_column(:message, Emojimmy.emoji_to_token(received_sms.message))
    end
    Message.find_each do |message|
      message.update_column(:message, Emojimmy.emoji_to_token(message.message))
    end
    Answer.find_each do |answer|
      answer.update_column(:value, Emojimmy.emoji_to_token(answer.value))
      answer.update_column(:short_value, Emojimmy.emoji_to_token(answer.short_value))
    end
    SentSms.find_each do |sent_sms|
      sent_sms.update_column(:message, Emojimmy.emoji_to_token(sent_sms.message))
    end
    Interaction.find_each do |interaction|
      interaction.update_column(:comment, Emojimmy.emoji_to_token(interaction.comment))
    end
  end
end