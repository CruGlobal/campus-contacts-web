require 'vpim/book'

class VcardsController < ApplicationController

  def create
     VcardMailer.enqueue.vcard(params[:email], params[:person_id])

     render nothing: true      
  end

  def bulk_create

    ids = params[:ids].split(',')

    if ids.present?

      respond_to do |wants|
        wants.html do
          if params.has_key?(:email)
            VcardMailer.enqueue.bulk_vcard(params[:email],  params[:ids])
            render nothing: true
          else
            send_data Person.vcard(ids), :type => 'application/vcard', :disposition => 'attachment', :filename => "contacts.vcf"
          end
        end
      end
    end

  end

end