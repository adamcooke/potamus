require 'yaml'
require 'open3'

module Potamus
  class Config

    def initialize(root)
      @root = File.expand_path(root)

      potamus_file_path = File.join(@root, 'PotamusFile')
      if File.file?(potamus_file_path)
        @options = YAML.load_file(potamus_file_path)
      else
        raise Error, "No Potamus file found at #{potamus_file_path}"
      end
    end

    def remote_name
      @options['remote_name'] || 'origin'
    end

    def branch_for_latest
      @options['branch_for_latest'] || 'master'
    end

    def image_name
      @options['image_name'] || raise(Error, "image_name is required in the PotomusFile")
    end

    def image_name_with_commit
      if @test_mode
        "#{image_name}:test"
      else
        "#{image_name}:#{commit}"
      end
    end

    def git?
      File.directory?(File.join(@root, '.git'))
    end

    def dirty?
      stdout, stderr, status = Open3.capture3("cd #{@root} && git status --short")
      unless status.success?
        raise Error, "Could not determine git status using `git status` (#{stderr})"
      end

      !stdout.strip.empty?
    end

    def commit
      get_commit_ref(branch)
    end

    def remote_commit
      get_commit_ref("#{remote_name}/#{branch}")
    end

    def pushed?
      commit == remote_commit
    end

    def branch
      stdout, stderr, status = Open3.capture3("cd #{@root} && git symbolic-ref HEAD")
      unless status.success?
        raise Error, "Could not get current commit (#{stderr})"
      end

      stdout.strip.sub('refs/heads/', '')
    end

    def build_command
      [
        "cd #{@root}",
        '&&',
        'docker', 'build', '.', '-t', image_name_with_commit,
        '--build-arg', 'commit_ref=' + commit,
        '--build-arg', 'branch=' + branch
      ].join(' ')
    end

    def tags
      return [] if @test_mode

      array = []
      array << branch
      array << 'latest' if branch == branch_for_latest
      array
    end

    def tag_commands
      tags.each_with_object({}) do |tag, hash|
        hash[tag] = tag_command(tag)
      end
    end

    def push_commands
      if @test_mode
        return { 'test' => push_command('test') }
      end

      hash = {}
      hash[commit] = push_command(commit)
      tags.each do |tag|
        hash[tag] = push_command(tag)
      end
      hash
    end

    def test_mode!
      @test_mode = true
    end

    private

    def tag_command(tag)
      ['docker', 'tag', image_name_with_commit, "#{image_name}:#{tag}"].join(' ')
    end

    def push_command(tag)
      ['docker', 'push', "#{image_name}:#{tag}"].join(' ')
    end

    def get_commit_ref(branch)
      stdout, stderr, status = Open3.capture3("cd #{@root} && git log #{branch} -n 1 --pretty='%H'")
      unless status.success?
        raise Error, "Could not get commit for #{branch} (#{stderr})"
      end

      stdout.strip
    end
  end
end
