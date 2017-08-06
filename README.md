# Subj

Сделать назначение программ обучения: 
администратор назначает группе пользователей и/или 
конкретным пользователям курсы и/или тесты, 
а они их проходят. 

Все детали прорабатывать не надо, 
достаточно за час-два сделать ключевое, 
на Ваш взгляд, в этой задаче, чтобы остальные 
члены команды могли доделать мелочи.

# Flow

Сущности:
---------
* user
* role: роль пользователя
* group: группа пользователей
* task: курсы и/или тесты
* assignment: связывает модели User и Task
* status: статус assignment-а

Services:
---------
* админ назначает *tasks* конкретному *пользователю* (по *user id*)
* админ назначает *tasks* конкретной *группе* пользователей (по *group id*)
* админ просматривает *весь список групп* и назначенные им *tasks*
* админ просматривает *весь список пользователей* и назначенные им *tasks*
* пользователь меняет статус своей *назначенной задачи* на *in_progress* и *done*
* админ меняет статус *выполненной задачи* на *approved* или на *declined*
* пользователь не может удалить свои *назначенные задачи*

App
---

* Для решения тестового задания предполагаем,
что в проекте используется rails 5 и devise.

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

Создаём модели
--------------

```
$ rails g model Task title
$ rails g model User title role group
$ rails g model Assignment user:references task:references status
```

Модель Task
-----------
* Связываем с моделью 'User':

```ruby
class Task < ActiveRecord::Base
    has_many :users, through :assignments
end
```

Модель User
-----------
* Перечисляем в ней роли, группы и назначаем дефолтные значения
при создании.
* Связываем с моделью 'Task': 

```ruby
class User < ActiveRecord::Base
  has_many :assignments
  has_many :tasks, through: :assignments
   
  enum role: [:user, :admin]
  enum group: [:moscow, :spb, :sochi, :none]
  
  after_initialize :set_default_role, :if => :new_record?
  after_initialize :set_default_group, :if => :new_record?

  private

  def set_default_role
    self.role ||= :user
  end
  
  def set_default_group
    self.group ||= :none
  end

end
```

Модель Assignment
-----------------

* Связываем с моделями `User` и `Task`
* перечисляем возможные статусы и назначаем дефолтный при создании

```ruby
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
```

# Маршруты

```ruby
    resources :users do
      resources :assignments
    end
```

# Контроллеры

```
$ rails g controller tasks to_users to_groups 
$ rails g controller users index show
$ rails g controller assignments new create update delete
```

Проверяем API
---------

```bash

curl -X POST localhost:3000/tasks/to_users -d 'task_ids=1,2,3&user_ids=1,2,3'

curl -X POST localhost:3000/tasks/to_groups -d 'task_ids=5&group_ids=1'

curl -X GET localhost:3000/users

curl -X GET localhost:3000/users/1

curl -X PUT localhost:3000/users/1/assignments/1 -d 'status=done'

curl -X PUT localhost:3000/users/1/assignments/1 -d 'status=approved'

curl -X DELETE localhost:3000/users/1/assignments/1

```