if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    match 'tickets_assistant_settings', :to => 'tickets_assistant_settings#index', :via => :get
    match 'tickets_assistant_settings/:id', :to => 'tickets_assistant_settings#edit', :via => :get
    match 'tickets_assistant_settings/:id/new', :to => 'tickets_assistant_settings#new', :via => :post
    match 'tickets_assistant_settings/:id/save', :to => 'tickets_assistant_settings#save', :via => :post

    match 'issues/:issue_id/zerofy_et', :to => 'ta_issue#zerofy_et', :via => :post
    match 'issues/:issue_id/set_et_to_st', :to => 'ta_issue#set_et_to_st', :via => :post
    match 'issues/:issue_id/normalize_et', :to => 'ta_issue#normalize_et', :via => :post
    match 'issues/:issue_id/reassign_to_default', :to => 'ta_issue#reassign_to_default', :via => :post
    match 'issues/:issue_id/close_and_next_resolved', :to => 'ta_issue#close_and_next_resolved', :via => :post
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.connect 'tickets_assistant_settings', :controller => 'tickets_assistant_settings', :action => 'index', :conditions => {:method => :get}
    map.connect 'tickets_assistant_settings/:id', :controller => 'tickets_assistant_settings', :action => 'edit', :conditions => {:method => :get}
    map.connect 'tickets_assistant_settings/:id/new', :controller => 'tickets_assistant_settings', :action => 'new', :conditions => {:method => :post}
    map.connect 'tickets_assistant_settings/:id/save', :controller => 'tickets_assistant_settings', :action => 'save', :conditions => {:method => :post}

    map.connect 'issues/:issue_id/zerofy_et', :controller => 'ta_issue', :action => 'zerofy_et', :conditions => {:method => :post}
    map.connect 'issues/:issue_id/set_et_to_st', :controller => 'ta_issue', :action => 'set_et_to_st', :conditions => {:method => :post}
    map.connect 'issues/:issue_id/normalize_et', :controller => 'ta_issue', :action => 'normalize_et', :conditions => {:method => :post}
    map.connect 'issues/:issue_id/reassign_to_default', :controller => 'ta_issue', :action => 'reassign_to_default', :conditions => {:method => :post}
    map.connect 'issues/:issue_id/close_and_next_resolved', :controller => 'ta_issue', :action => 'close_and_next_resolved', :conditions => {:method => :post}
  end
end