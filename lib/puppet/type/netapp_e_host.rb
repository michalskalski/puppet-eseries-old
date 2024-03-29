require 'puppet/util/network_device'
Puppet::Type.newtype(:netapp_e_host) do
  @doc = 'Manage Netapp E series hosts'

  apply_to_device
  ensurable

  validate do
    raise Puppet::Error, 'You must specify a storage system.' unless @parameters.include?(:storagesystem)
    raise Puppet::Error, 'You must specify a name of host.' unless @parameters.include?(:name)
    raise Puppet::Error, 'You must specify a group name' unless @parameters.include?(:groupid)
    raise Puppet::Error, 'You must specify a typeindex of host' unless @parameters.include?(:typeindex)
  end

  newparam(:name, :namevar => true) do
    desc 'The user-label to assign to the new host.'
  end

  newproperty(:storagesystem, :readonly => true) do
    desc 'Storage system ID'
  end

  newproperty(:typeindex) do
    desc 'HostType index'
  end

  newproperty(:groupid) do
    desc 'Name of host group where host belongs'
    munge do |value|
      begin
        hg_id = provider.transport.host_group_id(@resource[:storagesystem], value)
        if hg_id
          hg_id
        else
          { :value => value }
        end
      rescue
        Puppet.debug("#{value} not interpolated to group id, assume that group id is explicit given")
        value
      end
    end
  end

  newproperty(:ports, :array_matching => :all) do
    desc 'Host addresses'
  end
end
