class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  enum status: [:new, :in_progress, :done, :approved, :declined]
  after_initialize :set_default_status, :if => :new_record?

  private

  def set_default_status
    self.status ||= :new
  end

end