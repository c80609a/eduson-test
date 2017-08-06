class User < ApplicationRecord
  has_many :assignments
  has_many :tasks, through: :assignments

  enum role: [:user, :admin]
  enum group: [:msk, :spb, :sochi, :no_group]

  after_initialize :set_default_role, if: :new_record?
  after_initialize :set_default_group, if: :new_record?

  private

  def set_default_role
    self.role ||= :user
  end

  def set_default_group
    self.group ||= :no_group
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

end