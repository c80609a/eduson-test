require 'rails_helper'

RSpec.describe User, type: :model do

  # Association tests
  it { should have_many(:assignments) }
  it { should have_many(:tasks) }

  # Validation tests
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it 'Новая запись после создания имеет роль ":user", если роль не была указана при создании'
  it 'Новая запись после создания состоит в группе ":no_group", если группа не была указана при создании'

end
