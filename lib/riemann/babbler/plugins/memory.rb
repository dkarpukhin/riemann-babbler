class Riemann::Babbler::Memory < Riemann::Babbler

  def collect
    m = File.read('/proc/meminfo').split(/\n/).inject({}) { |info, line|
      x = line.split(/:?\s+/)
      info[x[0]] = x[1].to_i
      info
    }
    free = m['MemFree'].to_i + m['Buffers'].to_i + m['Cached'].to_i
    total = m['MemTotal'].to_i
    fraction = 1 - (free.to_f / total)

    desc = "usage\n\n#{shell('ps -eo pmem,pid,comm | sort -nrb -k1 | head -10').chomp}"

    [
      { :service => plugin.service, :metric => fraction },
      { :service => plugin.service + " free", :metric => free.to_f, :state => 'ok', :description => desc },
      { :service => plugin.service + " total", :metric => total.to_f, :state => 'ok', :description => desc }
    ]
  end

end
