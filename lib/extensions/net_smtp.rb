# frozen_string_literal: true

ROOT_DIR = File.dirname(File.dirname(File.dirname(__FILE__)))

def random_proxy
  return unless ["1", "true"].include?(ENV['USE_PROXIES'])

  path = File.join(ROOT_DIR, 'proxy.json')
  return unless File.readable?(path)

  proxies = JSON.parse(File.read(path))
  return if proxies.blank?

  proxy = proxies.sample
  "socks5://#{proxy['host']}:#{proxy['port']}"
end

module Net
  class SMTP
    # Monkey Patch to ensure SMTP uses proxies if available.
    def tcp_socket(address, port)
      if (proxy = random_proxy)
        puts "  trying: #{address} - from: #{proxy}"
        Proxifier::Proxy(proxy).open(address, port)
      else
        TCPSocket.open(address, port)
      end
    end
  end
end
