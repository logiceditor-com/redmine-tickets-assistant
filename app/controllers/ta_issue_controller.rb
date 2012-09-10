class TaIssueController < ApplicationController
  unloadable



  def index
  end


  def assist
    settings = get_settings

    if settings == nil
      flash[:error] = 'Tickets Assistant: settings not found'
      redirect_to :controller => 'tickets_assistant_settings', :action => 'edit', :id => settingsId
    else
      issue = Issue.find_by_id(params[:issue_id])

      #if issue.estimated_hours == nil && issue.spent_hours == 0
      #
      #end
      #
      flash[:notice] = 'assist ' + params[:issue_id]
      redirect_to :controller => 'issues', :action => 'show', :id => params[:issue_id]
    end

  end

  def zerofy_et
    issue = Issue.find_by_id(params[:issue_id])
    issue.estimated_hours = 0;
    issue.save

    comment = "ET was set to zero because of ST=0"
    post_comment(issue, comment);

    flash[:notice] = comment
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def set_et_to_st
    flash[:notice] = "not implemented yet"
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def normalize_et
    flash[:notice] = "not implemented yet"
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def reassign_to_default
    flash[:notice] = "not implemented yet"
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  private

  PREFIX = "_[tickets_assistant]_ "

  def get_settings
    settingsId = 1
    TicketsAssistantSettings.find_by_id(settingsId)
  end

  def post_comment(issue, text)
    comment = Journal.new :notes => (PREFIX + text)
    comment.user = User.current
    comment.journalized = issue
    comment.save
  end

  def humanize_hours(hours)
    hours = hours.to_f
    h = hours.floor
    m = ((hours - h) * 60).round

    res = ""
    if(h > 0)
      res += "#{h}h"
    end
    if(m > 0)
      res += "#{m}m"
    end

    if res.empty?
      res = "none"
    end

    res
  end

end
