#!/usr/bin/env ruby
keylocation = "/nfs/puppet/dist/keys"
initlocation = "/etc/puppet/modules-prod/sshkeys/manifests"
fullpath = File.join(initlocation, "init.pp")

File.delete(fullpath) if File.file?(fullpath)

f = File.new(fullpath,  "w")

nastystring = String.new("class sshkeys {\n  sshkey {\n")

Dir.chdir(keylocation)
hostlist = Dir.glob("*.mochimedia.net")
hostlist.each do |host|
  nastystring << "    " + host.split('.')[0] + ":\n"
  nastystring << "      ensure  => present,\n"
  nastystring << "      name    => \"" + host.split('.')[0] + "\",\n"
  nastystring << "      alias   => \"" + host + "\",\n"
  nastystring << "      type    => \"ssh-rsa\",\n"
  nastystring << "      key     => sprintf(\"\%s\%s\",regsubst(file(\"/nfs/puppet/dist/keys/" + host + "/ssh_host_rsa_key.pub\"), '^ssh\\-rsa\\s(.*)(\\s).*\$', '\\1'),"+host.split('.')[0] +");\n"
end

nastystring << "  }\n}\n"
f.write(nastystring)
f.close()
sleep(2)
Dir.chdir(initlocation)
exec 'svn commit -m "ssh key auto-commit"'
