module Landrush
  module Cap
    module Linux
      module CreateDnsmasqConfig
        class << self
          def create_dnsmasq_config(env, _ip, tld)
            @env = env
            @tld = tld
            if contents_match?
              info 'Host dnsmasq config looks good.'
            else
              info 'Need to configure dnsmasq on host.'
              write_config!
            end
          end

          private

          def info(msg)
            @env.ui.info("[landrush] #{msg}") unless @env.nil?
          end

          def config_dir
            @config_dir ||= Pathname('/etc/dnsmasq.d')
          end

          def desired_contents
            <<-EOS.gsub(/^ +/, '')
            # Generated by landrush, a vagrant plugin
            server=/#{@tld}/127.0.0.1#10053
            EOS
          end

          def config_file
            config_dir.join("vagrant-landrush-#{@tld}")
          end

          def contents_match?
            config_file.exist? && File.read(config_file) == desired_contents
          end

          def write_config!
            info 'Momentarily using sudo to put the host config in place...'
            system "sudo mkdir #{config_dir}" unless config_dir.directory?
            Tempfile.open('vagrant_landrush_host_config') do |f|
              f.write(desired_contents)
              f.close
              system "sudo cp #{f.path} #{config_file}"
              system "sudo chmod 644 #{config_file}"
            end
          end

          def ensure_config_exists!
            if contents_match?
              info 'Host DNS resolver config looks good.'
            else
              info 'Need to configure the host.'
              write_config!
            end
          end
        end
      end
    end
  end
end
