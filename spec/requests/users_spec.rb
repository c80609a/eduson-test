require 'rails_helper'

RSpec.describe 'Users', type: :request do

  context 'devise related tests' do
    describe 'GET /users/sign_up' do
      it 'Пользователь не может зарегистрироваться, если на такой email уже заведён аккаунт'
      it 'Пользователь может зарегистрироваться при отправке правильных данных'
      it 'После успешной регистрации пользователь автоматически авторизован'
    end

    describe 'POST /users/sign_in' do
      it 'Пользователь не может авторизоваться, если он не зарегистрирован'
      it 'Пользователь может авторизоваться при отправке правильных данных email/password'
    end

    describe 'DELETE /users/sign_out' do
      it 'Пользователь может успешно выйти'
    end
  end

end
