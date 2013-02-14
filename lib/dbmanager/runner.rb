# The runner main responsibility is to interact with the user in order to gather
# the information to accomplish the task.
#
# The runner object cannot do much when freshly instantiated, so for each kind
# of available task there is a corresponding module that can extend the runner
# so that it can accomplish its goal.
#
# Extension modules must define the #run method which contains the specific
# behaviour they provide.

module Dbmanager
  class Runner
    attr_reader :input, :output, :source

    def self.run(module_name)
      runner = new
      runner.extend Dbmanager.const_get(module_name.capitalize)
      runner.run
    end

    def initialize(input=STDIN, output=STDOUT)
      @input        = input
      @output       = output
      @source       = get_env
    end

    def environments
      @environments ||= YmlParser.environments
    end

    def get_env(type='source')
      output.puts "\nPlease choose #{type} db:\n\n"
      get_environment
    end

    def get_filename type, default_filename
      output.print "\nPlease choose #{type} file (defaults to #{default_filename}): "
      filename = input.gets.chomp
      filename.blank? ? default_filename : Dbmanager.rails_root.join(filename)
    end


    private

    def get_environment
      environments.keys.each_with_index do |name, i|
        output.puts "#{i+1}) #{name}"
      end
      output.puts
      pos = ''
      until (1..environments.size).include? pos
        pos = input.gets.chomp.to_i
      end
      environments.values[pos-1]
    end
  end
end
