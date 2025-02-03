class Collaboration < ApplicationRecord
  belongs_to :consultant
  belongs_to :collaborator, class_name: 'ConsultantTeam'

  enum status: %i[pending approved]

  validates_presence_of :consultant, :collaborator
end
