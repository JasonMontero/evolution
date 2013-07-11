# == Schema Information
#
# Table name: questions
#
#  id             :integer          not null, primary key
#  qdata          :text
#  answer         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  examination_id :integer
#  type           :integer
#  correct        :boolean
#

class Question < ActiveRecord::Base
  attr_accessible :answer, :qdata

  validates :answer, :presence => true
  validates :qdata, :presence => true

  has_many :examination_questions
  has_many :examinations, :through => :examination_questions

  has_many :user_answers

end
