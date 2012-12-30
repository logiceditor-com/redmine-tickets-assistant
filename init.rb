require 'redmine'
require 'dispatcher'

require 'TAIssuesHelperPatch'
require 'TAIssuesControllerPatch'
require 'TAMailerPatch'

Dispatcher.to_prepare :redmine_tickets_assistant do
  require_dependency 'issues_helper'
  IssuesHelper.send(:include, TAIssuesHelperPatch)

  require_dependency 'issues_controller'
  IssuesController.send(:include, TAIssuesControllerPatch)

  require_dependency 'mailer'
  Mailer.send(:include, TAMailerPatch)
end

Redmine::Plugin.register :redmine_tickets_assistant do
  name 'Redmine Tickets Assistant plugin'
  author 'Alexey Romanov'
  description 'Tickets manage assistant'
  version '0.0.5'
  url 'http://logiceditor.com'
  author_url 'http://logiceditor.com'

  project_module :tickets_assistant do
    permission :tickets_assistant_settings_edit, :tickets_assistant_settings => :edit
    menu :admin_menu, :tickets_assistant_settings, { :controller => 'tickets_assistant_settings', :action => 'edit', :id => 1 }, :caption => 'Tickets assistant'
  end

end
