module View
  # Topology controller's CUI.
  class Text
    def initialize(logger)
      @logger = logger
    end

    def add_switch(_dpid, _topology)
      # show_status("Switch #{dpid.to_hex} added", topology.switches.map(&:to_hex))
      puts '## add_switch'
    end

    def delete_switch(_dpid, _topology)
      # show_status("Switch #{dpid.to_hex} deleted", topology.switches.map(&:to_hex))
      puts '## del_switch'
    end

    def add_port(port, topology)
      puts '## add_port'
      add_or_delete_port :added, port, topology
    end

    def delete_port(port, topology)
      puts '## del_port'
      add_or_delete_port :deleted, port, topology
    end

    def add_link(port_a, port_b, _topology)
      link = format('%#x-%#x', *([port_a.dpid, port_b.dpid].sort))
      # show_status "Link #{link} added", topology.links
      puts '## add_link'
    end

    def delete_link(port_a, port_b, _topology)
      link = format('%#x-%#x', *([port_a.dpid, port_b.dpid].sort))
      # show_status "Link #{link} deleted", topology.links
      puts '## del_link'
    end

    def to_s
      'text mode'
    end

    private

    def add_or_delete_port(_message, port, topology)
      ports = topology.ports[port.dpid].map(&:number).sort
      # show_status "Port #{port.dpid.to_hex}:#{port.number} #{message}", ports
      # puts "## add_or_delete_port"
    end

    def show_status(message, objects)
      status = objects.sort.map(&:to_s).join(', ')
      @logger.info "#{message}: #{status}"
    end

    ## show all switches and links when all action
    def modify_switch
      puts '--------------------'
      ## show all switch
      switches = topology.switches.map(&:to_hex)
      show_status 'All switches', switches
      puts '--------------------'
    end

    def modify_port
      puts '--------------------'
      ## show all port
      # topology.links.each do |each|
      puts '--------------------'
    end

    def modify_link
      puts '--------------------'
      ## show all link
      links = topology.links
      show_status 'All links', links
      puts '--------------------'
    end
  end
end
