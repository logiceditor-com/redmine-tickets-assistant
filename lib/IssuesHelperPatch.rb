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
      if !isButton
        return issue_heading_without_patch(issue)
      end

      needShowButton = issue.status.name == "Resolved" && issue.assigned_to_id == User.current.id
      buttonText = "???"

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
          break true
        else
          settings = TicketsAssistantSettings.find_by_id(TA_SETTINGS_ID)
          excludes = settings.exclude_reassign_user_ids.split ","
          break excludes.find_index(issue.assigned_to_id.to_s) == nil
        end
      }

      check_issue_has_category = lambda {
        if issue.category_id == nil
          break IssueCategory.find_by_project_id(issue.project_id) == nil
        end

        true
      }

      check_issue_is_current_version = lambda {
        version = Version.find_by_project_id(issue.project_id)
        if version == nil then
          break true
        end

        settings = TicketsAssistantSettings.find_by_id(TA_SETTINGS_ID)
        active_versions_source = settings.active_versions.split ","
        project_has_active_version = false
        is_version_current = false
        active_versions_source.map do |pair|
          key_value = pair.split "="
          project_id = key_value[0].to_i
          if project_id == issue.project_id
            project_has_active_version = true
            version_id = key_value[1].to_i
            if version_id == issue.fixed_version_id
              is_version_current = true
              break
            end
          end
        end

        is_version_current || !project_has_active_version
      }

      warningText = nil
      hourToleranceError = 0.001

      buttonWidth = 100
      buttonHeight = 20

      if issue.estimated_hours == nil && issue.spent_hours == 0
        action = "zerofy_et"
        color = "#FF5304"
        if !needShowButton
          warningText = "Warning! ET not set"
        end
        buttonText = "ET -> 0"
      elsif issue.spent_hours > 0 && (issue.estimated_hours == nil || issue.spent_hours - issue.estimated_hours > hourToleranceError)
        action = "set_et_to_st"
        color = "#FF001F"
        if !needShowButton
          warningText = "Warning! ET not set"
        end
        buttonText = "ET -> ST"
      elsif issue.estimated_hours != nil && issue.estimated_hours > issue.spent_hours && issue.estimated_hours - issue.spent_hours > hourToleranceError
        action = "normalize_et"
        color = "#DFFFDF"
        buttonText = "ET -> ST"
      elsif !check_issue_closable.call
        errorText = "This ticket can not be closed now"
        color = "#646464"
      elsif check_assignee_not_in_excludes.call
        action = "reassign_to_default"
        color = "#9FCF9F"
        #color = "#6DFF00"
        settings = TicketsAssistantSettings.find_by_id(TA_SETTINGS_ID)
        user = User.find_by_id(settings.reassign_user_id)
        if user
          buttonWidth = 250
          buttonText = "assign to " + user.name
        end
      elsif !check_issue_has_category.call
        warningText = "Warning! Issue has not category"
        errorText = "Please set issue category first"
        color = "#FFFFFF"
      elsif !check_issue_is_current_version.call
        warningText = "Warning! Issue is not current version"
        errorText = "Need to be current version"
        color = "#FFFFFF"
      else
        if(issue.estimated_hours - issue.spent_hours > hourToleranceError)
          warningText = "Warning: ET - ST = " + (issue.estimated_hours - issue.spent_hours).to_s
        end
        action = "close_and_next_resolved"
        color = "#9FCF9F"
        buttonText = "close and next resolved"
        buttonWidth = 200
      end

      if needShowButton
        if errorText != nil
          button = "
          <button
            style='width: #{buttonWidth}px; height: #{buttonHeight}px; background-color: #{color};'
            onclick='alert(\"#{errorText}\")'
          >#{buttonText}</button>
        "
        else
          form = form_tag("/issues/#{issue.id}/#{action}")
          button = "
          <button
            style='width: #{buttonWidth}px; height: #{buttonHeight}px; background-color: #{color};'
          >#{buttonText}</button>
        "
          button = form + button + "</form>"
        end
      else
        button = ""
      end

      res = button
      if warningText != nil
        res = "<p>#{warningText}</p>" + res
      end

      return res
    end

    #- "private" ----------------------------------------------


  end

  #module_function :assist_button
end

