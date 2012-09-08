class TicketsAssistantSettingsController < ApplicationController
  unloadable

  #def index
  #  @presets = TicketsAssistantSettings.find(:all)
  #end

  def save
    if User.current.admin?
      formData = params[:tickets_assistant_settings]
      @preset = TicketsAssistantSettings.find_by_id(params[:id])
      if(formData[:exclude_reassign_user_ids] != nil)
        @preset.exclude_reassign_user_ids = formData[:exclude_reassign_user_ids].join(",")
      else
        @preset.exclude_reassign_user_ids = ""
      end
      @preset.reassign_user_id = formData[:reassign_user_id]
      if @preset.save
        flash[:notice] = 'Settings saved.'
        redirect_to :action => 'edit', :id => params[:id]
      end
    else
      flash[:error] = 'Permission denied.'
      redirect_to :controller => 'issues', :action => 'index'
    end
  end

  def edit
    if User.current.admin?
      @preset = TicketsAssistantSettings.find_by_id(params[:id])
    else
      flash[:error] = 'Permission denied.'
      redirect_to :controller => 'issues', :action => 'index'
    end
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    #@project = Project.find(params[:project_id])
  end
end
