#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'xmlrpc/client'

class ZenossHandler < Sensu::Handler

  def event_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def should_send
    if @event['occurrences'] > 0
      return true
    end
  end

  def filter_repeated
    occurrences = @event['check']['occurrences'] || 1
    interval    = @event['check']['interval']    || 30
    refresh     = @event['check']['refresh']     || 60
    if @event['occurrences'] < occurrences
      bail 'not enough occurrences'
    end
    if @event['occurrences'] > occurrences && @event['action'] == 'create'
      number = refresh.fdiv(interval).to_i
      unless number == 0 || @event['occurrences'] % number == 0
        bail 'only handling every ' + number.to_s + ' occurrences'
      end
    end
  end

  def handle
    begin

      if should_send 
        timeout(15) do
          conn_args = {
            #:user => settings['zenoss']['username'],
            #:password => settings['zenoss']['password'],
            #:host => settings['zenoss']['host'],
            :user => "admin",
            :password => "adminAdm1n11",
            :host => "testtpzenmgr01",
            :port => 8080,
            :path => '/zport/dmd/ZenEventManager'
          }
          connection = XMLRPC::Client.new_from_hash(conn_args)
        
          if @event['check']['status'] == 0
            event = {:device => "#{@event['client']['name']}", :component => "#{@event['check']['name']}", :summary => "#{@event['check']['output']}", :message => "#{@event['check']['output']}", :severity => 0, :eventClass => '/Sensu'}
          elsif @event['check']['status'] == 1
            event = {:device => "#{@event['client']['name']}", :component => "#{@event['check']['name']}", :summary => "#{@event['check']['output']}", :message => "#{@event['check']['output']}", :severity => 3, :eventClass => '/Sensu'} 
          elsif @event['check']['status'] == 2
            event = {:device => "#{@event['client']['name']}", :component => "#{@event['check']['name']}", :summary => "#{@event['check']['output']}", :message => "#{@event['check']['output']}", :severity => 5, :eventClass => '/Sensu'}
          end

          connection.call('sendEvent', event)
        end
      end

    rescue => e
      puts "#{e.message}"
    end
  end

end
