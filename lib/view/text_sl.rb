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
      # show_status("Switch #{dpid.to_hex} added", topology.switches.map(&:to_hex))
      #puts topology.switches.size
      show_all_switch(dpid, topology)
    end

    def delete_switch(dpid, topology)
      # show_status("Switch #{dpid.to_hex} deleted", topology.switches.map(&:to_hex))
      show_all_switch(dpid, topology)
    end

    def add_port(port, topology)
      # add_or_delete_port :added, port, topology
    end

    def delete_port(port, topology)
      # add_or_delete_port :deleted, port, topology
    end

    def add_link(port_a, port_b, topology)
      # if (topology.links.size == 10)
      #   #system("rvmsudo /share/home/kudo/trema/topology/bin/trema stop 0x1")
      #   %x(sudo ovs-vsctl del-br br0x1)
      #   #system("rvmsudo /share/home/kudo/trema/topology/bin/trema port_down -s 0x1 -p 1")
      #   #system("sudo ovs-ofctl mod-port br0x1 0x1_1 down")
      #   @startTime = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      # end
      # link = format("%#x-%#x", *([port_a.dpid, port_b.dpid].sort))
      # show_status "Link #{link} added", topology.links
      show_all_link(port_a, port_b, topology)
    end

    def delete_link(port_a, port_b, topology)
      # puts Time.now.to_f - @startTime.to_f
      # if (topology.links.size == 0)
      #   puts Process.clock_gettime(Process::CLOCK_MONOTONIC) - @startTime
      # end
      # link = format("%#x-%#x", *([port_a.dpid, port_b.dpid].sort))
      # show_status "Link #{link} deleted", topology.links
      show_all_link(port_a, port_b, topology)
    end

    def add_host(mac_address, port, _topology)
      ## original show_status for add_host
      @logger.info "Host #{mac_address} added to Port #{port}"
      puts "--------------------"
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
    def show_all_switch(_dpid, topology)
      ## show all switch
      switches = topology.switches.map(&:to_hex)
      show_status "All switches", switches
      puts "--------------------"
    end

    def show_all_link(_port_a, _port_b, topology)
      ## show all link
      links = topology.links
      show_status "All links", links
      # puts topology.links.size
      puts "--------------------"
    end

    def show_status(message, objects)
      status = objects.sort.map(&:to_s).join(", ")
      @logger.info "#{message}: #{status}"
    end
  end
end
