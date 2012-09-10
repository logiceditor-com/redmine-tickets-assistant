require_dependency 'issues_controller'

module IssuesControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def assist
      a = 5
    end
  end

end
