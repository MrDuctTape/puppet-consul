Facter.add(:consul_downloaddir) do
  confine :osfamily => :windows
  setcode do
    program_data = `echo %SYSTEMDRIVE%\\ProgramData`.chomp
    if File.directory? program_data
      "#{program_data}\\puppet-archive"
    else
      "C:\\Puppet-Archive"
    end
  end
end
