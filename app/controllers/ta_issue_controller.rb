class TaIssueController < ApplicationController
  unloadable

  def zerofy_et
    issue = Issue.find_by_id(params[:issue_id])
    issue.estimated_hours = 0
    issue.save

    comment = "ET was set to zero because of ST=0"
    post_comment(issue, comment)

    flash[:notice] = comment
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def set_et_to_st
    issue = Issue.find_by_id(params[:issue_id])
    issue.estimated_hours = issue.spent_hours
    issue.save

    comment = "ET was set to ST because of lack of ET"
    post_comment(issue, comment)

    flash[:notice] = comment
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def normalize_et
    issue = Issue.find_by_id(params[:issue_id])
    issue.estimated_hours = issue.spent_hours
    issue.save

    comment = "ET was set to ST"
    post_comment(issue, comment)

    flash[:notice] = comment
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def reassign_to_default
    flash[:notice] = "not implemented yet"
    redirect_to :controller => 'issues', :action => 'show', :id => issue.id
  end

  def close_and_next_resolved
    issue = Issue.find_by_id(params[:issue_id])
    issueStatus = IssueStatus.find_by_name("Closed")
    issue.status = issueStatus
    issue.save

    issueResolvedStatus = IssueStatus.find_by_name("Resolved")
    settings = get_settings
    if settings == nil
      flash[:error] = "No settings defined, please save one"
      redirect_to :controller => 'tickets_assistant_settings', :action => 'edit', :id => 1
    else
      userId = settings.reassign_user_id
      userForReassign = User.find_by_id(userId)
      if userForReassign != nil
        issueForRedirect = Issue.find_by_assigned_to_id_and_status_id(userId, issueResolvedStatus.id)

        if issueForRedirect != nil
          flash[:notice] = "'#{issue.subject}' was closed"
          redirect_to :controller => 'issues', :action => 'show', :id => issueForRedirect.id
        else
          flash[:notice] = "'#{issue.subject}' was closed. There were no more resolved tickets for #{userForReassign.name}."
          redirect_to :controller => 'issues', :action => 'show', :id => issue.id
        end
      else
        flash[:error] = "No reassign user selected, please edit settings"
        redirect_to :controller => 'tickets_assistant_settings', :action => 'edit', :id => 1
      end
    end
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
