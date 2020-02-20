# frozen_string_literal: true

command :run do
  desc 'Run the image'

  option '--test', 'Run in test mode' do |value, options|
    options[:test] = true
  end

  option '-c [COMMAND]', '--command [COMMAND]', 'Specify the command to run' do |value, options|
    options[:command] = value
  end

  action do |context|
    require 'potamus/config'
    require 'fileutils'
    config = Potamus::Config.new(FileUtils.pwd)
    if context.options[:test]
      puts "\e[33mRunning in test mode...\e[0m"
      config.test_mode!
    end

    unless context.options[:test]
      unless config.git?
        raise Error, "This directory containing your PotamusFile doesn't seem to be a git repository"
      end

      if config.dirty?
        raise Error, "Working copy is dirty. Commit all changes before building."
      end

      unless config.pushed?
        raise Error, "Your local commit does not match the commit on your remote repository. Have you pushed?"
      end
    end

    command = context.options[:command] || "/bin/bash"
    system("docker run -it --rm #{config.image_name_with_commit} #{command}")
  end
end
