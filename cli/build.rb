# frozen_string_literal: true

command :build do
  desc 'Build the current version of the app'

  option '-p', '--push', 'Push to registry after build' do |value, options|
    options[:push] = true
  end

  option '--test', 'Run in test mode' do |value, options|
    options[:test] = true
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

    system(config.build_command) || raise(Error, "Failed to build image")

    config.tag_commands.each do |tag, command|
      system(command) || raise(Error, "Could not create tag for #{tag}")
      puts "Created tag for #{config.image_name}:#{tag}"
    end

    if context.options[:push]
      config.push_commands.each do |tag, command|
        system(command) || raise(Error, "Failed to push #{tag} to registry")
      end
    end
  end
end
