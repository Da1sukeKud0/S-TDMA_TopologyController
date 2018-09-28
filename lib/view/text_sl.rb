module View
  # Topology controller's CUI.
  ##
  ## this mode only detect modify of switch and link (sl mode).
  ## Usage: require "view/text_sl" in command_line.rb
  ##
  class Text
    def initialize(logger)
      @logger = logger
    end

    def add_switch(dpid, topology)
      #show_status("Switch #{dpid.to_hex} added", topology.switches.map(&:to_hex))
      show_all_switch(dpid, topology)
    end

    def delete_switch(dpid, topology)
      #show_status("Switch #{dpid.to_hex} deleted", topology.switches.map(&:to_hex))
      show_all_switch(dpid, topology)
    end

    def add_port(port, topology)
      #add_or_delete_port :added, port, topology
    end

    def delete_port(port, topology)
      #add_or_delete_port :deleted, port, topology
    end

    def add_link(port_a, port_b, topology)
      #link = format("%#x-%#x", *([port_a.dpid, port_b.dpid].sort))
      #show_status "Link #{link} added", topology.links
      show_all_link(port_a, port_b, topology)
    end

    def delete_link(port_a, port_b, topology)
      #link = format("%#x-%#x", *([port_a.dpid, port_b.dpid].sort))
      #show_status "Link #{link} deleted", topology.links
      show_all_link(port_a, port_b, topology)
    end

    def to_s
      "text mode"
    end

    private

    def add_or_delete_port(message, port, topology)
      ports = topology.ports[port.dpid].map(&:number).sort
      show_status "Port #{port.dpid.to_hex}:#{port.number} #{message}", ports
    end

    ## show all switches and links when all action
    def show_all_switch(dpid, topology)
      puts "--------------------"
      ## show all switch
      switches = topology.switches.map(&:to_hex)
      show_status "All switches", switches
    end

    def show_all_link(port_a, port_b, topology)
      puts "--------------------"
      ## show all link
      links = topology.links
      show_status "All links", links
    end

    def show_status(message, objects)
      status = objects.sort.map(&:to_s).join(", ")
      @logger.info "#{message}: #{status}"
    end
  end
end
