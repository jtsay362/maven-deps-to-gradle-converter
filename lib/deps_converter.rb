#!/usr/bin/env ruby

class DepsConverter
  SCOPES = ['compile', 'test', 'runtime', 'provided']

  def initialize
    @debug_enabled = false
  end

  def convert(deps_filename)
    build_deps(deps_filename)

    debug @deps

    build_dep_info

    debug @dep_info

    output_add_dependencies_method

    output_dep_info_maps

    puts

    output_dependency_additions
  end

  private

  def dep_info_variable_name(scope)
    "#{scope}DepInfo"
  end

  def group_location(dep)
    "#{dep_info_variable_name(dep[:scope])}['#{dep[:group_id]}']"
  end

  def build_deps(deps_filename)
    @deps = []

    File.open(deps_filename) do |file|
      file.readlines.each do|line|

        if line.match(/^\[DEBUG\]\s{4}([\w+\.\-]+):([\w+\.\-]+):([\w+\.\-]+)(:([\w+\.\-]+))?:([\w+\.\-]+):(\w+)\s*$/)
          group_id , artifact_id, packaging, classifier, version, scope = $1, $2, $3, $5, $6, $7

          debug "Found matching line: '#{line}'"

          dep = {
              group_id: group_id,
              artifact_id: artifact_id,
              packaging: packaging,
              scope: scope
          }

          if classifier
            dep[:classifier] = classifier
          end

          dep[:version] = version

          debug "Parsed dependency: #{dep}"

          @deps.push(dep)
        end
      end
    end

    @deps
  end


  def build_dep_info
    @dep_info = {}
    @deps.each do |dep|
      scope = @dep_info[dep[:scope]]

      if !scope
        scope = {}
        @dep_info[dep[:scope]] = scope
      end

      group = scope[dep[:group_id]]

      if !group
        group = {}
        scope[dep[:group_id]] = group
      end

      group[dep[:artifact_id]] = dep
    end

    @dep_info
  end

  def output_add_dependencies_method
    puts <<-HERE
def addDependencies(configurationName, depInfo) {
  depInfo.each {
    def group = it.key
    def nameToInfoMap = it.value
    nameToInfoMap.each {
      def name = it.key
      def info = it.value
      dependencies.add(configurationName, [group: group, name: name] + info)
    }
  }
}
HERE
    puts
  end

  def output_dep_info_maps
    SCOPES.each do |scope|
      output_dep_info_map_for_scope(scope)
      puts
    end
  end

  def output_dep_info_map_for_scope(scope)
    print "def #{scope}DepInfo = ["

    first_group = true

    dep_info_for_scope = @dep_info[scope]

    dep_info_for_scope.keys.sort.each do |group_id|
      if first_group
        puts
        first_group = false
      else
        puts ','
      end

      print "  '#{group_id}' : ["

      first_version = true

      dep_info_for_scope[group_id].each_pair do |artifact_id, dep|
        if first_version
          puts
        else
          puts ','
        end

        first_version = false

        print "    '#{artifact_id}' : [version: '#{dep[:version]}'"

        if (dep[:classifier])
          print ", classifier: '#{dep[:classifier]}'"
        end

        print ']'

      end

      puts
      print '  ]'
    end

    puts
    puts ']'
  end

  def output_dependency_additions
    SCOPES.each do |scope|
      output_dependency_addition_for_scope(scope)
    end
  end

  def output_dependency_addition_for_scope(scope)
    configuration = translate_dependency_configuration(scope)

    puts "addDependencies('#{configuration}', #{dep_info_variable_name(scope)})"
  end

  def debug(msg)
    puts("DEBUG: #{msg}") if @debug_enabled
  end

  def translate_dependency_configuration(scope)
    case scope
      when 'test'
        'testCompile'
      when 'provided'
        'providedCompile'
      else
        scope
    end
  end
end

if ARGV.empty?
  puts "Usage: deps_converter <dependencies_filename>"
else
  DepsConverter.new.convert(ARGV[0])
end
