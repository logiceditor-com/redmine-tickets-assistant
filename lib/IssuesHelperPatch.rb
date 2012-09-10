module IssuesHelperPatch
  def self.included(base) # :nodoc:
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
    def issue_heading_with_patch(issue)
      original = issue_heading_without_patch(issue)

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
          return false
        }

        check_issue_has_category = lambda {
          false
        }

        check_issue_is_current_version = lambda {
          false
        }

        if issue.estimated_hours == nil && issue.spent_hours == 0
          action = "zerofy_et"
          color = "#FF5304"
        #elsif issue.estimated_hours == nil && issue.spent_hours > 0
        #  action = "set_et_to_st"
        #  color = "#FF001F"
        #elsif issue.estimated_hours != nil && issue.estimated_hours > issue.spent_hours
        #  action = "normalize_et"
        #  color = "#A8FF00"
        elsif !check_issue_closable.call
          errorText = "This ticket can not be closed now"
          color = "#646464"
        elsif check_assignee_not_in_excludes.call
          action = "reassign_to_default"
          color = "#6DFF00"
        elsif !check_issue_has_category.call
          errorText = "Warning! Issue has not category"
          color = "#FFFFFF"
        elsif !check_issue_is_current_version.call
          errorText = "Warning! Issue is not current version'"
          color = "#FFFFFF"
        else
          action = "next_resolved"
          color = "#6DFF00"
        end

        if errorText != nil
          button = "
            <button
              style='width: 50px; height: 50px; background-color: #{color};'
              onclick='alert(\"#{errorText}\")'
            ></button>
          "
        else
          button = "
            <form method='post' action='/issues/#{issue.id}/#{action}'>
              <button
                style='
                  width: 50px;
                  height: 50px;
                  background-color: #{color};
                '
                onclick='alert(123)'
              ></button>
            </form>
          "
        end

        res = button + original
      else
        res = original
      end

      return res
    end

    #- "private" ----------------------------------------------


  end
end

