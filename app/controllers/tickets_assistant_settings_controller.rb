class TicketsAssistantSettingsController < ApplicationController
  unloadable

  def new
    if User.current.admin?
      formData = params[:tickets_assistant_settings]
      @preset = TicketsAssistantSettings.new
      @preset.id = params[:id]
      @preset.save
      save
    else
      flash[:error] = 'Permission denied.'
      redirect_to :controller => 'issues', :action => 'index'
    end
  end

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

      if(formData[:active_versions] != nil)
        active_versions = ""
        formData[:active_versions].each do |project_id, version_id|
          if version_id != ""
            if active_versions.length > 0
              active_versions += ","
            end
            active_versions += project_id + "=" + version_id
          end
        end
        @preset.active_versions = active_versions
      else
        @preset.active_versions = ""
      end

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
      if !@preset
        @preset = TicketsAssistantSettings.new()
        flash[:notice] = 'It\'s unsaved settings'
      end
    else
      flash[:error] = 'Permission denied.'
      redirect_to :controller => 'issues', :action => 'index'
    end
  end

  private

end
