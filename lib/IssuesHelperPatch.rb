module IssuesHelperPatch
  TA_SETTINGS_ID = 1

  def self.included(base) # :nodoc:
    #base.extend(ClassMethods)
    if !base.method_defined?(:issue_heading_without_patch)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :issue_heading, :patch
      end
    else
      base.class_eval do
        alias_method :issue_heading, :issue_heading_with_patch
      end
    end
  end

  module InstanceMethods
  #module ClassMethods
    def issue_heading_with_patch(issue, isButton = false)
  #  def assist_button(issue)
      if !isButton
        return issue_heading_without_patch(issue)
      end

      if issue.status.name == "Resolved"
        check_issue_closable = lambda {
          allowedStatuses = issue.new_statuses_allowed_to(User.current)
          hasClosed = false
          allowedStatuses.map do |allowedStatus|
            if allowedStatus.name == "Closed"
              hasClosed = true
            end
          end
          hasClosed
        }
        check_assignee_not_in_excludes = lambda {
          if issue.assigned_to_id == nil
            return true
          else
            settings = TicketsAssistantSettings.find_by_id(TA_SETTINGS_ID)
            excludes = settings.exclude_reassign_user_ids.split ","
            return excludes.find_index(issue.assigned_to_id.to_s) == nil
          end
        }

        #check_issue_has_category = lambda {
        #  false
        #}
        #
        #check_issue_is_current_version = lambda {
        #  false
        #}

        warningText = nil

        if issue.estimated_hours == nil && issue.spent_hours == 0
          action = "zerofy_et"
          color = "#FF5304"
        elsif issue.estimated_hours == nil && issue.spent_hours > 0
          action = "set_et_to_st"
          color = "#FF001F"
        elsif issue.estimated_hours != nil && issue.estimated_hours > issue.spent_hours && issue.estimated_hours - issue.spent_hours > 0.001
          action = "normalize_et"
          color = "#A8FF00"
        elsif !check_issue_closable.call
          errorText = "This ticket can not be closed now"
          color = "#646464"
        elsif check_assignee_not_in_excludes.call
          action = "reassign_to_default"
          color = "#6DFF00"
        #elsif !check_issue_has_category.call
        #  warningText = "Warning! Issue has not category"
        #  color = "#FFFFFF"
        #elsif !check_issue_is_current_version.call
        #  warningText = "Warning! Issue is not current version'"
        #  color = "#FFFFFF"
        else
          if(issue.estimated_hours > issue.spent_hours)
            warningText = "Warning: ET - ST = " + (issue.estimated_hours - issue.spent_hours).to_s
          end
          action = "close_and_next_resolved"
          color = "#009F00"
        end

        buttonWidth = 100
        buttonHeight = 20
        if errorText != nil
          button = "
            <button
              style='width: #{buttonWidth}px; height: #{buttonHeight}px; background-color: #{color};'
              onclick='alert(\"#{errorText}\")'
            ></button>
          "
        else
          form = form_tag("/issues/#{issue.id}/#{action}")
          button = "
            <button
              style='width: #{buttonWidth}px; height: #{buttonHeight}px; background-color: #{color};'
            ></button>
          "
          button = form + button + "</form>"
        end

        res = button # + original
        if warningText != nil
          res = "<p>#{warningText}</p>" + res
        end
      else
        res = ""
      end

      return res
    end

    #- "private" ----------------------------------------------


  end

  #module_function :assist_button
end

