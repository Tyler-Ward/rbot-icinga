#++
#
# :title: Icinga plugin for rbot
#
# Author:: Tyler Ward

#require 'nagios/status.rb'

class IcingaPlugin < Plugin

  Config.register Config::ArrayValue.new('icinga.channels',
    :default => [],
    :desc => "List of channels to announce icinga messages to")

  Config.register Config::StringValue.new('icinga.pipe',
    :default => '',
    :desc => "pipe file to read messages from")

  Config.register Config::StringValue.new('icinga.commandfile',
    :default => '/var/lib/icinga/rw/icinga.cmd',
    :desc => "comand file to pass icinga comands to")

  def initialize
    super
    @channels = @bot.config['icinga.channels']
    @pipefile = @bot.config['icinga.pipe']
    @commandfile = @bot.config['icinga.commandfile']
    if @channels.empty? or @pipefile.empty?
      error "icinga.pipe or icinga.channels config is unset!"
    else
      log "Starting icinga and announcing on channels #{@channels.join(', ')}"
      icinga()
    end
  end

  def help(plugin, topic="")
    return 	"icinga notification plugin, \n" +
		"ack host [hostname] [comment] - acknoladges a host problem, \n" +
		"ack service [hostname] [service] [comment] - acknowledges a service problem, "
  end


  def icinga()
    begin
      input = open(@pipefile, "r+")
#      m.reply "starting icinga on #{params[:channel]}"
#      m.reply "#{m.channel} #{params[:channel]}"

      Thread.start {
        while( line = input.gets )
#          m.reply "\x0304 #{line}"
          @channels.each do |chan|
	    @bot.say chan.strip, line
	  end
#  	  puts "#{line}"
        end
      }
    rescue
      log "error in icinga plugin"
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

Icinga.map 'ack host :host *string', :action => 'acknowledgehost'
Icinga.map 'ack service :host :service *string', :action => 'acknowledgeservice'


