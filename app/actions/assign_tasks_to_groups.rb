# Назначить *tasks* конкретным *группам*.
#
# Принимает params вида 'task_ids=1,2,3&groups=msk,spb'.
#
# Если среди task_ids присутствует id несуществующей записи -
# в базу не будет ничего записано.
#
# Если среди groups присутствуют несуществующие группы -
# perform вернёт warnings сообщения, а задачи назначены будут
# пользователям из существующих групп.

class AssignTasksToGroups

  def initialize(params)
    @params = params
  end

  def perform

    # соберём параметры для создания Assignments
    new_assignments = []
    #
    warnings = []

    # обработаем входящие параметры
    @params[:groups].split(',').each do |group|
      users = User.try(group)

      if users.nil?
        warnings << "Группы #{group} не существует"
        next
      elsif users.size.zero?
        warnings << "В группе #{group} нет пользователей"
        next
      end

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

    if new_assignments.size.zero? && warnings.size > 0
      raise ArgumentError.new('В указанных группах нет пользователей.')
    else
      # если дошли до сюда - значит с данными всё впорядке, помещаем их в базу
      Assignment.create!(new_assignments)
      warnings << 'Задачи назначены указаным пользователям'
    end

    warnings.join(',')
  end

end