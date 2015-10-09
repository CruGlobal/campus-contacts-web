class Signature < ActiveRecord::Base
  SIGNATURE_CODE_OF_CONDUCT = 'code_of_conduct'
  SIGNATURE_STATEMENT_OF_FAITH = 'statement_of_faith'
  SIGNATURE_STATUS_ACCEPTED = 'accepted'
  SIGNATURE_STATUS_DECLINED = 'declined'

  SIGNATURES = [SIGNATURE_CODE_OF_CONDUCT, SIGNATURE_STATEMENT_OF_FAITH]
  SIGNATURE_STATUSES = [SIGNATURE_STATUS_ACCEPTED, SIGNATURE_STATUS_DECLINED]

  attr_accessible :person_signature_id, :kind, :status
  belongs_to :person
  belongs_to :organization
end
