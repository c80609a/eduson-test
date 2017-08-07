require 'rails_helper'

RSpec.describe 'Assignments API', type: :request do

  let!(:tasks) { create_list(:task, 3) }
  let(:task_ids) { tasks.map { |task| task.id }.join(',') }

  describe 'POST /assignments/to_users' do

    let!(:users) { create_list(:default_user, 3) }
    let(:user_ids) { users.map { |user| user.id }.join(',') }

    let(:valid_params) do
      {
          user_ids: user_ids,
          task_ids: task_ids
      }
    end
    let(:invalid_user_params) do
      {
          user_ids: make_corrupt_ids_map(users),
          task_ids: task_ids
      }
    end
    let(:invalid_task_params) do
      {
          user_ids: user_ids,
          task_ids: make_corrupt_ids_map(tasks)
      }
    end

    context 'Если запрос валидный:' do
      before { post '/assignments/to_users', params: valid_params }
      it 'Пользователям будут назначены задачи' do
        expect(response).to have_http_status(201)
      end
      it 'Сервер вернёт сообщение об успехе' do
        expect(json['message']).to match(/Задачи назначены/)
      end
    end

    context 'Если запрос невалидный:' do
      context 'Если неверный параметр `user_ids`' do
        before { post '/assignments/to_users', params: invalid_user_params }
        it 'Всем указанным пользователям не будут назначены задачи' do
          expect(response).to have_http_status(404)
        end
        it 'Сервер сообщит, какой user_id является ошибочным' do
          expect(json['message']).to match(/Couldn't find User with/)
        end
      end
      context 'Если неверный параметр `task_ids` - присутствуют несуществующие задачи' do
        before { post '/assignments/to_users', params: invalid_task_params }
        it 'Всем указанным пользователям не будут назначены задачи' do
          expect(response).to have_http_status(404)
        end
        it 'Сервер сообщит, какой task_id является ошибочным' do
          expect(json['message']).to match(/Couldn't find Task with/)
        end
      end
    end

  end

  describe 'POST /assignments/to_groups' do

    let!(:users) { create_list(:grouped_user, 3) }
    let(:groups) { users.map { |u| u.group }.join(',') }

    let(:valid_params) do
      {
          groups: groups,
          task_ids: task_ids
      }
    end
    let(:invalid_group_params) do
      {
          groups: make_corrupt_map(users, 'group'),
          task_ids: task_ids
      }
    end
    let(:invalid_task_params) do
      {
          groups: groups,
          task_ids: make_corrupt_ids_map(tasks)
      }
    end

    context 'Если запрос валидный:' do
      before { post '/assignments/to_groups', params: valid_params }
      it 'Пользователям будут назначены задачи' do
        expect(response).to have_http_status(201)
      end
      it 'Сервер вернёт сообщение об успехе' do
        expect(json['message']).to match(/Задачи назначены/)
      end
    end

    context 'Если запрос невалидный:' do

      context 'Если неверный параметр `groups`:' do
        context 'Присутствуют несуществующие группы' do
          before { post '/assignments/to_groups', params: invalid_group_params }
          it 'Всем найденным пользователям будут назначены задачи' do
            expect(response).to have_http_status(201)
          end
          it 'Сервер сообщит, каких групп не существует' do
            expect(json['message']).to match(/не существует/)
          end
        end
      end

      context 'Если неверный параметр `task_ids`' do
        before { post '/assignments/to_groups', params: invalid_task_params }
        it 'Всем указанным пользователям не будут назначены задачи' do
          expect(response).to have_http_status(404)
        end
        it 'Сервер сообщит, какой task_id является ошибочным' do
          expect(json['message']).to match(/Couldn't find Task with/)
        end
      end
    end

  end

end
