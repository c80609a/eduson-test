require 'rails_helper'

RSpec.describe Assignment, type: :model do

  it { should belong_to(:user) }
  it { should belong_to(:task) }

  it 'Новая запись после создания имеет статус ":fresh"'

end
