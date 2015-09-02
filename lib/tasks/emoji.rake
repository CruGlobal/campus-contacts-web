require 'emojimmy'
namespace :emoji do
  task :convert_to_token => :environment do
    ReceivedSms.all.each do |received_sms|
      received_sms.update_attribute(:message, Emojimmy.emoji_to_token(received_sms.message))
    end
    Message.all.each do |message|
      message.update_attribute(:message, Emojimmy.emoji_to_token(message.message))
    end
    Answer.all.each do |answer|
      answer.value = Emojimmy.emoji_to_token(answer.value)
      answer.short_value = Emojimmy.emoji_to_token(answer.short_value)
      answer.save
    end
    SentSms.all.each do |sent_sms|
      sent_sms.update_attribute(:message, Emojimmy.emoji_to_token(sent_sms.message))
    end
    Interaction.all.each do |interaction|
      interaction.update_attribute(:comment, Emojimmy.emoji_to_token(interaction.comment))
    end
  end
end