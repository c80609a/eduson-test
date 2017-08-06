class Task < ApplicationRecord
  has_many :users, through: :assignments
end
