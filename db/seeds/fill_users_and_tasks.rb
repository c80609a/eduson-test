# rake db:seed:fill_users_and_tasks

# создаём задачи
Task.create!({title:'task1'})
Task.create!({title:'task2'})
Task.create!({title:'task3'})
Task.create!({title:'task4'})

# по-умолчанию: user без группы
User.create!({email:'user@no_group.ru', :password => '123456', :password_confirmation => '123456'})

# user в группе sochi
User.create!({email:'user@sochi.ru', group:'sochi', :password => '123456', :password_confirmation => '123456'})

# admin в группе spb
User.create!({email:'admin@spb.ru', group:'spb', role:'admin', :password => '123456', :password_confirmation => '123456'})
