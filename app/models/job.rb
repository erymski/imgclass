class Job < ActiveRecord::Base
  belongs_to :image_label_set
  belongs_to :user
  has_many :image_labels

  before_destroy :reset_imagelabels


  def isOpen
    percent_remaining > 0
  end

  def isComplete
    ! isOpen
  end

  def percent_remaining
    @percent_remaining ||= ((remaining.to_f / image_labels.count) * 100.0).round(1)
  end

  def remaining
    @remaining ||= image_labels.where(:label_id => nil).size
  end

  def percent_agreement
    100
  end

  def reset_imagelabels
    image_labels.each do |il|
      il.job_id = nil
      il.save
    end
  end
end
