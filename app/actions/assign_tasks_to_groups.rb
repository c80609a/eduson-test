# Назначить *tasks* конкретным *группам*.
#
# Принимает params вида 'task_ids=1,2,3&group_ids=1,2,3'.
#
# если среди task_ids/group_ids присутствует id несуществующей записи -
# в базу не будет ничего записано.

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