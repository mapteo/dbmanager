require 'time'

module Dbmanager
  module Adapters
    module Mysql
      module Connectable
        def params(environment)
          [ "-u#{environment.username}",
            environment.flag(:password, :p),
            environment.flag(:host, :h),
            environment.flag(:port, :P),
            environment.database
          ].compact.join(' ')
        end
      end

      class Dumper
        include Connectable
        attr_reader :source, :filename

        def initialize(source, filename)
          @source   = source
          @filename = filename
        end

        def run
          Dbmanager.execute! dump_command
        end

        def dump_command
          "mysqldump #{ignoretables} #{params(source)} > #{filename}"
        end

        def ignoretables
          if source.ignoretables.present?
            source.ignoretables.inject [] do |arr, table|
              arr << "--ignore-table=#{source.database}.#{table}"
            end.join ' '
          end
        end
      end

      class Importer
        include Connectable
        attr_reader :source, :target, :tmp_file

        def initialize(source, target, tmp_file)
          @source   = source
          @target   = target
          @tmp_file = tmp_file
        end

        def run
          Dumper.new(source, tmp_file).run
          Dbmanager.execute! import_command
        ensure
          remove_tmp_file
        end

        def import_command
          unless target.protected?
            "mysql #{params(target)} < #{tmp_file}"
          else
            raise EnvironmentProtectedError
          end
        end

        def remove_tmp_file
          Dbmanager.execute "rm #{tmp_file}"
        end
      end
    end
  end
end
