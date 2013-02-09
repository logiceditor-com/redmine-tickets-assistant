module TAIssuesHelperPatch
  TA_SETTINGS_ID = 1
  DISABLED_BACKGROUND_COLOR = "#DDDDDD"
  DISABLED_TEXT_COLOR = "#AAAAAA"

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

      needEnableButton = issue.status.name == "Resolved" && issue.assigned_to_id == User.current.id
      buttonText = "no action"

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

      settings = TicketsAssistantSettings.find_by_id(TA_SETTINGS_ID)
      reassign_user = User.find_by_id(settings.reassign_user_id)

      method = :post

      if issue.estimated_hours == nil && issue.spent_hours == 0
        action = "zerofy_et"
        color = "#FFFF00"
        if !needEnableButton
          warningText = "Warning! ET not set"
        end
        buttonText = "ET -> 0"
      elsif issue.spent_hours > 0 && (issue.estimated_hours == nil || issue.spent_hours - issue.estimated_hours > hourToleranceError)

        action = "set_et_to_st"

        if issue.estimated_hours
          hours_left = issue.estimated_hours - issue.spent_hours
        end

        if hours_left && hours_left < 0 && hours_left > -1
          color = "#DFFFDF"
          buttonText = "ET ≈ ST"
          if !needEnableButton
            warningText = buttonText
          end
        else
          color = "#FF001F"
          buttonText = "ET -> ST"
          if !needEnableButton
            warningText = "Warning! ET not set"
          end
        end

      elsif issue.estimated_hours != nil && issue.estimated_hours > issue.spent_hours && issue.estimated_hours - issue.spent_hours > hourToleranceError
        action = "normalize_et"
        color = "#DFFFDF"
        buttonText = "ET -> ST"
      elsif !check_issue_closable.call
        hasBlocked = false
        blockedResolvedIssue = nil
        issue.relations.each do |relation|
          if relation.relation_type == "blocks" && relation.issue_to_id == issue.id && !relation.issue_from.closed?
            if relation.issue_from.status.to_s == "Resolved"
              blockedResolvedIssue = relation.issue_from
            end
            hasBlocked = true
            break
          end
        end

        if hasBlocked
          if blockedResolvedIssue
            buttonText = "Ticket blocked. Open blocker #" + blockedResolvedIssue.id.to_s
            issue = blockedResolvedIssue
            action = ""
            method = :get
          else
            warningText = "Warning: Ticket blocked"
            needEnableButton = false
          end
        end

      elsif check_assignee_not_in_excludes.call
        action = "reassign_to_default"
        color = "#9FCF9F"
        #color = "#6DFF00"
        if reassign_user
          buttonWidth = 250
          buttonText = "assign to " + reassign_user.name
        end
      elsif !check_issue_has_category.call
        warningText = "Warning! Issue has not category"
        errorText = "Please set issue category first"
        #color = "#FFFFFF"
        needEnableButton = false
      elsif !check_issue_is_current_version.call
        warningText = "Warning! Issue is not current version"
        errorText = "Need to be current version"
        #color = "#FFFFFF"
        needEnableButton = false
      else
        if(issue.estimated_hours - issue.spent_hours > hourToleranceError)
          warningText = "Warning: ET - ST = " + (issue.estimated_hours - issue.spent_hours).to_s
        end
        action = "close_and_next_resolved"
        color = "#9FCF9F"
        buttonText = "Close and show next ticket"
        if needEnableButton
          left = Issue.count(:all, :conditions => ['assigned_to_id = ? AND status_id = ?' , User.current.id, IssueStatus.find_by_name("Resolved").id])
          buttonText += " (#{left} left)"
        else
          warningText = "No more resolved tickets assigned to " + reassign_user.name
          color = DISABLED_TEXT_COLOR
        end
      end

      if !needEnableButton
        if warningText != nil
          buttonText = warningText
          textColor = color
        else
          textColor = DISABLED_TEXT_COLOR
        end
        color = DISABLED_BACKGROUND_COLOR
      elsif needEnableButton
        textColor = "#000000"
      end

      if !buttonText
        buttonText = " "
      end

      #style='width: #{buttonWidth}px; height: #{buttonHeight}px; background-color: #{color};'
      if errorText != nil
        button = "
        <button
          style='background-color: #{color};color: #{textColor};'
          onclick='alert(\"#{errorText}\")'
          #{needEnableButton ? "" : "disabled"}
        >#{buttonText}</button>
      "
      else
        action_path = "/issues/#{issue.id}"
        if action && action.length > 0
          action_path += "/#{action}"
        end

        form = form_tag(action_path, :method => method)

        button = "
        <button
          style='background-color: #{color};color: #{textColor};'
          #{needEnableButton ? "" : "disabled"}
        >#{buttonText}</button>
      "
        button = form + button + "</form>"
      end

      res = button

      return res
    end

    #- "private" ----------------------------------------------


  end

  #module_function :assist_button
end

