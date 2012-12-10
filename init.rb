require 'redmine'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

require 'IssuesHelperPatch'
require 'IssuesControllerPatch'

if Rails::VERSION::MAJOR >= 3
  require_dependency File.expand_path(File.join(File.dirname(__FILE__), 'app/controllers/tickets_assistant_settings_controller'))
  require_dependency File.expand_path(File.join(File.dirname(__FILE__), 'app/models/tickets_assistant_settings'))

  #views_dir = File.join(File.dirname(__FILE__), "app/views")
  #instance_variable_get("@inheritable_attributes")[:view_paths].unshift(views_dir)

  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'issues_helper'
    IssuesHelper.send(:include, IssuesHelperPatch)

    require_dependency 'issues_controller'
    IssuesController.send(:include, IssuesControllerPatch)
  end
else
  Dispatcher.to_prepare :redmine_tickets_assistant do
    require_dependency 'issues_helper'
    IssuesHelper.send(:include, IssuesHelperPatch)

    require_dependency 'issues_controller'
    IssuesController.send(:include, IssuesControllerPatch)
  end
end



Redmine::Plugin.register :redmine_tickets_assistant do
  name 'Redmine Tickets Assistant plugin'
  author 'Alexey Romanov'
  description 'Tickets manage assistant'
  version '0.0.1'
  url 'http://logiceditor.com'
  author_url 'http://logiceditor.com'

  project_module :tickets_assistant do
    permission :tickets_assistant_settings_edit, :tickets_assistant_settings => :edit
    menu :admin_menu, :tickets_assistant_settings, { :controller => 'tickets_assistant_settings', :action => 'edit', :id => 1 }, :caption => 'Tickets assistant'
  end

end
