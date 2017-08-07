# Назначить *tasks* конкретным *пользователям*.
#
# Принимает params вида 'task_ids=1,2,3&user_ids=1,2,3'.
#
# если среди task_ids/user_ids присутствует id несуществующей записи -
# в базу не будет ничего записано.

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
    'Задачи назначены указаным пользователям'
  end

end