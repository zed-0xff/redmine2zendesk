class Redmine2ZendeskIssueChangeListener < Redmine::Hook::Listener
  def controller_issues_bulk_edit_after_save(context={})
    controller_issues_edit_after_save(context)
  end
  def controller_issues_edit_after_save(context={})
    #if !Setting.plugin_redmine_updates_notifier[:ignore_api_changes] ||
    if context[:params][:format] != 'xml' && context[:issue] && context[:journal]
      ZendeskNotifier.notify! context
    end
  end
end

