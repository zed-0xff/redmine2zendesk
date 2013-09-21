require 'net/http'
require 'json'

class ZendeskNotifier
  def self.notify! context
    journal = context[:journal]
    issue = context[:issue]
    return if !issue || !journal

    # was the status changed?
    a = journal.details.where(prop_key:"status_id")
    return if a.empty?

    # was the new status one from array of interesting statuses?
    return unless Array(Setting.plugin_redmine2zendesk[:redmine_ticket_statuses]).map(&:to_s).
      include?(a.last.value.to_s)

    ticket_id_field = Setting.plugin_redmine2zendesk[:redmine_ticket_id_field].to_i
    if ticket_id_field <= 0
      Rails.logger.error "redmine2zendesk: Issue ##{issue.id}: no zendesk ticket id field ?!"
      return
    end
    zendesk_ticket_field = issue.custom_values.where(custom_field_id:ticket_id_field).first
    return unless zendesk_ticket_field # not associated with zendesk ticket

    zendesk_ticket_id = zendesk_ticket_field.value.to_i
    if zendesk_ticket_id <= 0
      Rails.logger.error "redmine2zendesk: Issue ##{issue.id}: cannot get zendesk ticket id from #{zendesk_ticket_field.inspect}"
      return
    end

    update_zendesk_ticket zendesk_ticket_id, issue, Setting.plugin_redmine2zendesk
  end

  private
  def self.update_zendesk_ticket zendesk_ticket_id, issue, params
    domain = params[:zendesk_subdomain] + ".zendesk.com"
    uri = URI("https://#{domain}/api/v2/tickets/#{zendesk_ticket_id}.json")

    # 'ticket' => { 'status' => 'pending' }
    h = {'ticket' => { params[:zendesk_ticket_field] => params[:zendesk_ticket_value] }}

    # send a comment, if any
    unless params[:zendesk_ticket_comment].to_s.strip.empty?
      h['ticket']['comment'] = {
        'public' => false,
        'body'   => params[:zendesk_ticket_comment].
          gsub('REDMINE_ISSUE_ID',     issue.id.to_s).
          gsub('REDMINE_ISSUE_STATUS', issue.status.name)
      }
    end

    req = Net::HTTP::Put.new(uri.path, 'Content-Type' => 'application/json')
    req.basic_auth params[:zendesk_user_email], params[:zendesk_user_password]
    req.body = h.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => (uri.scheme == 'https')) {|http|
      http.request(req)
    }
    #p res
    #p res.body
  rescue
    Rails.logger.fatal $!
  end
end
