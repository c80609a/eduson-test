class AssignmentsController < ApplicationController

  # PUT users/1/assignments/1 -d 'status=approved'
  def update
  end

  # DELETE users/1/assignments/1
  def destroy
  end

  # POST tasks/to_users -d 'task_ids=1,2,3&user_ids=1,2,3'
  def to_users
  end

  # POST tasks/to_groups -d 'task_ids=5&group_ids=1'
  def to_groups
  end
end
