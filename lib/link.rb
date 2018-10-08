require 'rubygems'
require 'pio/lldp'

#
# Edges between two switches.
#
class Link
  attr_reader :dpid_a
  attr_reader :dpid_b
  attr_reader :port_a
  attr_reader :port_b

  def initialize(dpid, packet_in)
      lldp = packet_in.data
      @dpid_a = lldp.dpid ## packet_in.data.lldp.dpid
      @dpid_b = dpid ##dest dpid
      @port_a = lldp.port_number ## packet_in.data.lldp.port_number
      @port_b = packet_in.in_port ## dest port
  end

  # def initialize(dpid, packet_in, *hst_mac)
  #   if hst_mac.length == 0
  #     lldp = packet_in.data
  #     @dpid_a = lldp.dpid ## packet_in.data.lldp.dpid
  #     @dpid_b = dpid ##dest dpid
  #     @port_a = lldp.port_number ## packet_in.data.lldp.port_number
  #     @port_b = packet_in.in_port ## dest port
  #   else
  #     @dpid_a = hst_mac[0] ## packet_in.data.lldp.dpid
  #     @dpid_b = dpid ##dest dpid
  #     @port_a = packet_in.transport_source_port ## packet_in.data.lldp.port_number
  #     @port_b = packet_in.in_port ## dest port
  #   end
  # end

  # rubocop:disable AbcSize
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable PerceivedComplexity
  def ==(other)
    ((@dpid_a == other.dpid_a) &&
     (@dpid_b == other.dpid_b) &&
     (@port_a == other.port_a) &&
     (@port_b == other.port_b)) ||
      ((@dpid_a == other.dpid_b) &&
       (@dpid_b == other.dpid_a) &&
       (@port_a == other.port_b) &&
       (@port_b == other.port_a))
  end
  # rubocop:enable AbcSize
  # rubocop:enable CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x-%#x', *([dpid_a, dpid_b].sort)
  end

  def connect_to?(port)
    dpid = port.dpid
    port_no = port.number
    ((@dpid_a == dpid) && (@port_a == port_no)) ||
      ((@dpid_b == dpid) && (@port_b == port_no))
  end
end
