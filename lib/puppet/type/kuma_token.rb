Puppet::Type.newtype(:kuma_token) do
  @doc = 'Generate kuma dataplane tokens'
  ensurable

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:path) do
    desc 'The path on the file system to write the dataplane token.'
  end

  newparam(:mesh) do
    desc 'The name of the kuma service mesh.'
  end

  newparam(:client_cert) do
    desc 'The public key content used for client authentication.'
  end

  newparam(:client_key) do
    desc 'The private key content used for client authentication.'
  end

  newparam(:control_plane) do
    desc 'The URL of the controlplane server.'
  end
end
