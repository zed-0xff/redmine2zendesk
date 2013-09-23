module Redmine2zendeskHelper
  def render_custom_fields_rows(issue)
    content = super
    ticket_id_field = Setting.plugin_redmine2zendesk[:redmine_ticket_id_field].to_i
    if ticket_id_field > 0
      if value = issue.custom_values.find{ |x| x.id == ticket_id_field }
        old_part = "<th>#{ h(value.custom_field.name) }:</th><td>#{ simple_format_without_paragraph(h(show_value(value))) }</td>"
        subdomain = Setting.plugin_redmine2zendesk[:zendesk_subdomain]
        zendesk_ticket_id = value.value.to_i
        url = "https://#{subdomain}.zendesk.com/agent/#/tickets/#{zendesk_ticket_id}"
        new_part = "<th>#{ h(value.custom_field.name) }:</th><td><a href=\"#{url}\">#{zendesk_ticket_id}</a></td>"
        return content.sub(old_part, new_part).html_safe
      end
    end
    content
  end
end
