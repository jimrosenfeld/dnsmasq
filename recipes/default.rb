package 'dnsmasq'

if platform_family?('debian')
  nologin_path = '/usr/sbin/nologin'
elsif platform_family?('rhel', 'fedora')
  nologin_path = '/sbin/nologin'
end

user node['dnsmasq']['user'] do
  shell nologin_path
  action [:create, :lock]
end

group node['dnsmasq']['group'] do
  members node['dnsmasq']['user']
  action :create
end

template '/etc/dnsmasq.d/user.conf' do
  source 'dynamic_config.erb'
  mode '0644'
  variables lazy {
    {
      :config => {
        'user': node['dnsmasq']['user'],
        'group': node['dnsmasq']['group'],
      },
    }
  }
  action :create
end

file '/etc/dnsmasq.conf' do
  mode '0644'
  content 'conf-dir=/etc/dnsmasq.d'
  notifies :restart, 'service[dnsmasq]', :delayed
end

include_recipe 'dnsmasq::dns' if node['dnsmasq']['enable_dns']
include_recipe 'dnsmasq::dhcp' if node['dnsmasq']['enable_dhcp']

service 'dnsmasq' do
  action [:enable, :start]
end
