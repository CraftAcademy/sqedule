class SchedulesController < ApplicationController
  require 'json'
  include SchedulesHelper
  respond_to :js
  
  def optimizer
    flash[:notice] = "Planning period is being optimized. Please wait..."
    @optimized_response =  SchedulesService.get_optimized_response(params[:optimizer_hash])
    
    @count = 0
    if Rails.env == 'test' || Rails.env == 'development'
      begin
      @optimized_response["assignments"].each do |assignment|
        if assignment["id"].nil?
          ##Create new assignment
          @staff = Staff.find(assignment["staff_id"])
          @staff.assignments.create(shift: assignment["shift"], date: assignment["date"])
          @count += 1
        else
          ##Update assignment
          @assignment= Assignment.find(assignment["id"])
          @assignment.update(shift: assignment["shift"], date: assignment["date"])
          @count += 1             
        end
      end
      rescue
      end
    end

    if @count > 0
      flash[:notice] = "Planning period has successfully updated with #{@count} new assignments"
    else
      flash[:notice] = "No updates were made"
    end
    @done = true
    render 'optimizer'
  end

  def new
    period_start = get_period_date(Schedule.find(request.referrer.split("/")[-1].delete("?").to_i).period)
    period_end = period_start.end_of_month
    shifts = Shift.where(pattern_id: current_user.patterns, date: (period_start..period_end))
    assignments = Assignment.where(staff_id: current_user.staffs, date: (period_start..period_end))
    @optimizer_hash = {shifts: [], assignments: [], patterns: [], staffs: []}
    shifts.each {|shift| @optimizer_hash[:shifts].push(JSON.parse(shift.to_json))}
    assignments.each {|assignment| @optimizer_hash[:assignments].push(JSON.parse(assignment.to_json))}
    current_user.patterns.each {|p| @optimizer_hash[:patterns].push(JSON.parse(p.to_json))}
    current_user.staffs.each {|s| @optimizer_hash[:staffs].push(JSON.parse(s.to_json))}
  end

  def create

  end

  def index
    @current_period = Schedule.find_by(period: Time.new.strftime("%Y-%m"))    
    redirect_to schedule_path(@current_period) if user_signed_in?    
  end

  def show
    @current_id = params[:id].to_i
    @schedule = Schedule.find(@current_id)
    @next_month = get_another_month(@current_id + 1)
    @prev_month = get_another_month(@current_id - 1)
    @staffs = current_user.staffs.all
    @patterns = current_user.patterns.all
    @shift = Shift.new
    @shifts = Shift.all
    @date_array = get_schedule_header(@schedule)
    @assignments = Assignment.all
  end

  private

  def get_another_month(id)
    begin
      Schedule.find(id)
    rescue
    end
  end

  def schedule_params
    params.require(:schedule).permit(:period)
  end

  
end