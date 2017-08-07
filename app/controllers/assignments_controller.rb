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
    message = AssignTasksToUsers.new(params).perform
    json_response({message: message}, :created)
  end

  # POST tasks/to_groups -d 'task_ids=5&groups=spb,abz'
  def to_groups
    message = AssignTasksToGroups.new(params).perform
    json_response({message: message}, :created)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_assignment
    @assignment = @user.assignments.find_by!(id: params[:id]) if @user
  end

end
