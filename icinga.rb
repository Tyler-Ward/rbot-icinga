#++
#
# :title: Icinga plugin for rbot
#
# Author:: Tyler Ward

#require 'nagios/status.rb'

class IcingaPlugin < Plugin

  def help(plugin, topic="")
    return 	"icinga notification plugin, \n" +
		"icinga [channel] - starts icinga reporting on channel, \n" +
		"ack host [hostname] [comment] - acknoladges a host problem, \n" +
		"ack service [hostname] [service] [comment] - acknowledges a service problem, "
  end

  def icinga(m, params)
    begin
      input = open("/var/lib/icinga/rw/CSLIBBot", "r+")
      m.reply "starting icinga on #{params[:channel]}"
#      m.reply "#{m.channel} #{params[:channel]}"

      Thread.start {
        while( line = input.gets )
#          m.reply "\x0304 #{line}"
	  @bot.say params[:channel], line
#  	  puts "#{line}"
        end
      }
    rescue
      m.reply "error in icinga plugin"
    end
  end

  def acknowledgehost(m,params)
    begin
      pipe = open("/var/lib/icinga/rw/icinga.cmd", "w+")
      time = Time.new
      Time.at(time)
      time=Time.now.to_i
      pipe.printf "[#{time}] ACKNOWLEDGE_HOST_PROBLEM;#{params[:host]};1;1;1;CSLIB;#{params[:string]}"
      pipe.flush
      m.reply "done"
    rescue
      m.reply "error knowleging problem"
    end
  end

  def acknowledgeservice(m,params)
    begin
      pipe = open("/var/lib/icinga/rw/icinga.cmd", "w+")
      time = Time.new
      Time.at(time)
      time=Time.now.to_i
      pipe.printf "[#{time}] ACKNOWLEDGE_SVC_PROBLEM;#{params[:host]};#{params[:service]};1;1;1;CSLIB;#{params[:string]}"
      pipe.flush
      m.reply "done"
    rescue
      m.reply "error knowleging problem"
    end
  end
  
end

Icinga = IcingaPlugin.new

Icinga.map 'icinga :channel'
Icinga.map 'ack host :host *string', :action => 'acknowledgehost'
Icinga.map 'ack service :host :service *string', :action => 'acknowledgeservice'


