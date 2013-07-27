require 'vpim/book'

class VcardsController < ApplicationController

  def create
     VcardMailer.vcard(params[:email], params[:person_id]).deliver

     render nothing: true      
  end

  def bulk_create
    ids = params[:ids]
    if ids.present?
      all_ids = ids.split(',')
      respond_to do |wants|
        wants.html do
          if params.has_key?(:email)
            if all_ids.count > 1
              VcardMailer.bulk_vcard(params[:email], all_ids, params[:note]).deliver!
            else
              VcardMailer.vcard(params[:email], ids, params[:note]).deliver!
            end
            render nothing: true
          else
            send_data Person.vcard(ids), :type => 'application/vcard', :disposition => 'attachment', :filename => "contacts.vcf"
          end
        end
      end
    end

  end

end