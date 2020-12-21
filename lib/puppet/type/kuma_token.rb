Puppet::Type.newtype(:kuma_token) do
  @doc = 'Manage st2 packs'
  ensurable

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:path) do
    desc 'Name of the pack.'
  end

  newparam(:mesh) do
    desc 'kuma service mesh'
  end

  newparam(:client_cert) do
    desc 'kuma service mesh'
  end

  newparam(:client_key) do
    desc 'kuma service mesh'
  end

  newparam(:control_plane) do
    desc 'kuma service mesh'
  end
end