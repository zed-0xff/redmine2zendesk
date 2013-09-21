require_dependency 'redmine2zendesk_issue_change_listener'

Redmine::Plugin.register :redmine2zendesk do
  name        'redmine2zendesk'
  author      'Andrey "Zed" Zaikin'
  description 'Zendesk ticket updater for Redmine'
  version     '0.0.1'
  url         'https://github.com/zed-0xff/redmine2zendesk'
  author_url  'http://zed.0xff.me'
  settings    partial:'redmine2zendesk/settings', default:{
    'zendesk_ticket_field' => "status",
    'zendesk_ticket_value' => "pending"
  }
end
