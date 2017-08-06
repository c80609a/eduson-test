# Summary

<ul style='list-style:none !important;'>
    <li><a href='#1-Subj'>1. Subj.</a></li>
    <li><a href='#2-Flow'>2. Flow.</a>
        <ul>
            <li><a href='#21-Описание-сущностей'>2.1. Описание сущностей.</a></li>
            <li><a href='#22-Создаём-приложение'>2.2. Создаём приложение.</a></li>
            <li><a href='#23-Создаём-модели'>2.3. Создаём модели.</a>
                <ul>
                   <li><a href='#231-Модель-Task'>2.3.1. Модель Task</a></li>                    
                   <li><a href='#232-Модель-User'>2.3.2. Модель User</a></li>                    
                   <li><a href='#233-Модель-Assignment'>2.3.3. Модель Assignment</a></li>                    
                </ul>
            </li>
            <li><a href='#24-Создаём-контроллеры'>2.4. Создаём контроллеры.</a></li>
            <li><a href='#25-Улучшим-контроллеры'>2.5. Улучшим контроллеры.</a></li>
            <li><a href='#26-Actions'>2.6. Добавляем service objects.</a></li>
            <li><a href='#27-Описание-маршрутов'>2.7. Описание маршрутов.</a></li>
            <li><a href='#28-Проверяем-модели'>2.8. Проверяем модели.</a></li>
            <li><a href='#29-Проверяем-api'>2.9. Проверяем API.</a></li>
        </ul>
    </li>
    <li><a href='#3-todo'>3. Todo</a>
</ul>

# 1. Subj

Сделать назначение программ обучения: 
администратор назначает группе пользователей и/или 
конкретным пользователям курсы и/или тесты, 
а они их проходят. 

Все детали прорабатывать не надо, 
достаточно за час-два сделать ключевое, 
на Ваш взгляд, в этой задаче, чтобы остальные 
члены команды могли доделать мелочи.

# 2. Flow

Процесс буду описывать последовательно, шаг за шагом.
В конце приведён TODO, чтобы "...остальные члены команды могли доделать мелочи".

## 2.1. Описание сущностей

* **user**
* **role**: роль пользователя: в рамках задачи добавил 2 роли: `:user` и `:admin`
* **group**: группа пользователей: в рамках задачи добавил 4 группы:
`:msk`, `:spb`, `:sochi`, `:no_group`
* **task**: курсы и/или тесты
* **assignment**: связывает модели User и Task
* **status**: статус assignment-а: в рамках задачи добавил 4 статуса:
    - `:fresh` - админ только-что назначил задачу пользователю
    - `:in_progress` - пользователь приступил к выполнению
    - `:done` - пользователь закончил выполнение назначенной задачи
    - `:approved` - админ проверил и подтвердил успешное выполнение задачи
    - `:declined` - админ проверил и отклонил решение

## 2.2. Создаём приложение

* Для решения тестового задания предполагаем, что в проекте используется rails 5 и devise.

```
$ ruby -v # ruby 2.3.3
$ rails -v # Rails 5.1.2
$ rails new eduson-test -T -d mysql --api
$ cd eduson-test
$ echo ruby-2.3.3 > .ruby-version
$ <add devise and service gems to Gemfile>
$ rails generate devise:install
$ bundle
```

## 2.3. Создаём модели

```
$ rails g model Task title
$ rails g devise User role:integer group:integer
$ rails g model Assignment user:references task:references status
```

### 2.3.1. Модель Task

* Связываем с моделью 'User':

```ruby
class Task < ActiveRecord::Base
    has_many :users, through: :assignments
end
```

### 2.3.2. Модель User

* Перечисляем в ней роли, группы и назначаем дефолтные значения при создании.
* Связываем с моделью 'Task': 

```ruby
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
```

### 2.3.3. Модель Assignment

* Связываем с моделями `User` и `Task`
* перечисляем возможные статусы и назначаем дефолтный при создании

```ruby
class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  enum status: [:fresh, :in_progress, :done, :approved, :declined]
  after_initialize :set_default_status, :if => :new_record?

  private

  def set_default_status
    self.status ||= :fresh
  end

end
```

## 2.4. Создаём контроллеры

```
$ rails g controller assignments update destroy to_users to_groups
$ rails g controller users index show
```

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  # GET users
  def index
    @users = User.all
    json_response(@users)
  end

  # GET users/1
  def show
    json_response(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

end

```

```ruby
# app/controllers/assignments_controller.rb

class AssignmentsController < ApplicationController

  before_action :set_user, :only => [:update, :destroy]
  before_action :set_user_assignment, :only => [:update, :destroy]

  # PUT users/1/assignments/1 -d 'status=approved'
  def update
    @assignment.status = params[:status]
    @assignment.save!
    head :no_content
  end

  # DELETE users/1/assignments/1
  def destroy
    @assignment.delete
    head :no_content
  end

  # POST tasks/to_users -d 'task_ids=1,2,3&user_ids=1,2,3'
  def to_users
    AssignTasksToUsers.new(params).perform
    head :no_content
  end

  # POST tasks/to_groups -d 'task_ids=5&group_ids=1'
  def to_groups
    AssignTasksToGroups.new(params).perform
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_assignment
    @assignment = @user.assignments.find_by!(id: params[:id]) if @user
  end

end
```

## 2.5. Улучшим контроллеры

Добавим пару `concerns`, помогающих с json-ответами и с обработкой исключений:

```ruby
# app/controllers/concerns/exception_handler.rb

module ExceptionHandler
  extend ActiveSupport::Concern

  included do

    # define custom handlers
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({message: e.message}, :not_found)
    end

  end

  private

  # JSON ответ со статус-кодом 422 - unprocessable_entity
  def four_twenty_two(e)
    json_response({message: e.message}, :unprocessable_entity)
  end

end
```

```ruby
# app/controllers/concerns/response.rb

module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
```

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
end
```

## 2.6. Actions

Директорая `actions` предназначена для *service objects*, 
которые не использут сторонние сервисы:

* [X] админ назначает *tasks* конкретному *пользователю* (по *user id*)
* [X] админ назначает *tasks* конкретной *группе* пользователей (по *group id*)

```ruby
# app/actions/assign_tasks_to_users.rb 

class AssignTasksToUsers

  def initialize(params)
    @params = params
  end

  def perform
    # соберём параметры для создания Assignments
    new_assignments = []

    # обработаем входящие параметры
    @params[:user_ids].split(',').each do |user_id|
      user = User.find(user_id.to_i)
      @params[:task_ids].split(',').each do |task_id|
        task = Task.find(task_id.to_i)
        new_assignments << {
            user_id: user.id,
            task_id: task.id
        }
      end
    end

    # если дошли до сюда - значит с данными всё впорядке, помещаем их в базу
    Assignment.create!(new_assignments)
  end

end
```

```ruby
# app/actions/assign_tasks_to_groups.rb

class AssignTasksToGroups

  def initialize(params)
    @params = params
  end

  def perform
    # соберём параметры для создания Assignments
    new_assignments = []

    # обработаем входящие параметры
    @params[:groups].split(',').each do |group|
      users = User.where(group: group)
      @params[:task_ids].split(',').each do |task_id|
        task = Task.find(task_id.to_i)
        users.each do |user|
          new_assignments << {
              user_id: user.id,
              task_id: task.id
          }
        end
      end
    end

    # если дошли до сюда - значит с данными всё впорядке, помещаем их в базу
    Assignment.create!(new_assignments)
  end

end
```

## 2.7. Описание маршрутов

```ruby
Rails.application.routes.draw do
  resources :users do
    resources :assignments, only: [:update, :destroy]
  end
  devise_for :users
  match 'assignments/to_users', to: 'assignments#to_users', via: :post
  match 'assignments/to_groups', to: 'assignments#to_groups', via: :post
end
```

## 2.8. Проверяем модели

```bash
$ rails c
```

Создаём 3-х пользователей:

```ruby
# по-умолчанию: user без группы
User.create!({email:'user@no_group.ru', :password => '123456', :password_confirmation => '123456'})
#=> #<User id: 1, email: "user@no_group.ru", role: "user", group: "no_group" ...

# user в группе sochi
User.create!({email:'user@sochi.ru', group:'sochi', :password => '123456', :password_confirmation => '123456'})
#=> #<User id: 2, email: "user@sochi.ru", role: "user", group: "sochi" ...

# admin в группе spb
User.create!({email:'admin@spb.ru', group:'spb', role:'admin', :password => '123456', :password_confirmation => '123456'})
#=> #<User id: 3, email: "admin@spb.ru", role: "admin", group: "spb" ...
```

Создаём задачи:

```ruby
Task.create!({title:'task1'})
Task.create!({title:'task2'})
Task.create!({title:'task3'})
Task.create!({title:'task4'})
```

Сложим создание моделей в seed файл `db/seeds/fill_users_and_tasks.rb`,
который исполняется командой `rake db:seed:fill_users_and_tasks`
с помощью `lib/tasks/custom_seed.rake`.

## 2.9. Проверяем API

```bash
$ curl -X GET localhost:3000/users
# получаем список всех пользователей:
# [{"id":2,"email":"user@sochi.ru","role":"user","group":"sochi","created_at":"2017-08-06T03:38:24.000Z","updated_at":"2017-08-06T03:38:24.000Z"},
# {"id":3,"email":"user@no_group.ru","role":"user","group":"no_group","created_at":"2017-08-06T03:38:50.000Z","updated_at":"2017-08-06T03:38:50.000Z"},
# {"id":4,"email":"admin@spb.ru","role":"admin","group":"spb","created_at":"2017-08-06T03:39:25.000Z","updated_at":"2017-08-06T03:39:25.000Z"}]

$ curl -X POST localhost:3000/assignments/to_users -d 'task_ids=1&user_ids=1'
# назначаем одному пользователю одну задачу
# в ответ приходит пустота - все корректно

$ curl -X POST localhost:3000/assignments/to_users -d 'task_ids=1,2&user_ids=1,2'
# назначаем многим пользователям много задач
# в ответ приходит пустота - все корректно

$ curl -X POST localhost:3000/assignments/to_users -d 'task_ids=1,2&user_ids=1,2,11'
# назначаем многим пользователям много задач: среди user_ids есть несуществующий пользователь
# {"message":"Couldn't find User with 'id'=11"}

$ curl -X POST localhost:3000/assignments/to_groups -d 'task_ids=1,2&groups=sochi'
# назначаем одной группе c одним пользователем 2 задачи
#  SQL (0.6ms)  INSERT INTO `assignments` (`user_id`, `task_id`, ...) VALUES (2, 1, 0, ...)
#  SQL (0.6ms)  INSERT INTO `assignments` (`user_id`, `task_id`, ...) VALUES (2, 2, 0, ...)
# в ответ приходит пустота - все корректно

$ curl -X POST localhost:3000/assignments/to_groups -d 'task_ids=1,2&groups=sochi'
# назначаем одной группе (без пользователей) 2 задачи
# в базу ничего не кладётся
# в ответ приходит пустота - все корректно

$ curl -X POST localhost:3000/assignments/to_groups -d 'task_ids=5&group=user'
# назначаем группе задачи: среди task_ids есть несуществующая задача
{"message":"Couldn't find Task with 'id'=5"}

$ curl -X GET localhost:3000/users/11
# ищем инфо о несуществующем пользователе
# {"message":"Couldn't find User with 'id'=11"}

$ curl -X GET localhost:3000/users/3
# получаем инфо о существующем пользователе
# {"id":3,"email":"user@no_group.ru","role":"user","group":"no_group","created_at":"2017-08-06T03:38:50.000Z","updated_at":"2017-08-06T03:38:50.000Z"}

$ curl -X PUT localhost:3000/users/1/assignments/1 -d 'status=done'
# обновляем статус назначенной задачи
# SQL (0.1ms) UPDATE `assignments` SET `status` = 2  ...
# в ответ приходит пустота - все корректно

$ curl -X PUT localhost:3000/users/1/assignments/11 -d 'status=done'
# пытаемся обновить статус несуществующего assignment-a
# {"message":"Couldn't find Assignment with [WHERE `assignments`.`user_id` = ? AND `assignments`.`id` = ?]"}

$ curl -X DELETE localhost:3000/users/1/assignments/1
# Удаляем у пользователя назначенную задачу
# SQL (112.2ms)  DELETE FROM `assignments` WHERE `assignments`.`id` = 1
# в ответ приходит пустота - все корректно
```

# 3. TODO

* [ ] Авторизовать запросы: 
    - [ ] список всех пользователей может получить только админ
    - [ ] Назначать `tasks` может только админ
    - [ ] Менять статусы `assignment`-ов на `approved`/`declined` может только админ
    - [ ] Пользователь может менять статус только своих `assignment`-ов
    - [ ] Удалять `assignments` может только админ

* [X] `AssignmentsController#to_users`: если среди `task_ids`/`user_ids` 
присутствует `id` несуществующей записи - не пройдёт весь запрос, т.е.
в базу не будет ничего записано

* [X] `AssignmentsController#to_groups`: если среди `task_ids`/`group_ids` 
присутствует `id` несуществующей записи - не пройдёт весь запрос, т.е.
в базу не будет ничего записано
    
* [ ] Пользователь может изменить статус только своих `assignment`-ов     
* [ ] Пользователь может изменить статус своего `fresh assignment`-а только на `in_progress`
* [ ] Пользователь может изменить статус своего `in progress assignment`-а только на `done`
* [ ] Пользователь не может изменить статус своих `assignment`-ов со статусом `approved`/`declined`   
* [ ] Админ может изменить статус `assignment`-ов только на `approved`/`declined`
     
* [ ] Покрыть код тестами:
     - [ ]
     - [ ]
     - [ ]
     - [ ]
     - [ ]