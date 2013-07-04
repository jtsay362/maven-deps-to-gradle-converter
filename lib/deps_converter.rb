#!/usr/bin/env ruby

class DepsConverter
  def initialize
    @debug_enabled = false
  end

  def convert(deps_filename)
    build_deps(deps_filename)

    debug @deps

    build_versions

    debug @versions

    output_version_map

    puts

    output_dependencies

  end

  private

  def group_location(dep)
    "depVersions['#{dep[:group_id]}']"
  end

  def version_location(dep)
    "#{group_location(dep)}['#{dep[:artifact_id]}']"

  end

  def make_name(name)
    camel_case name.gsub(/[\.\-]/, "_")
  end

  def camel_case(phrase)
    phrase.downcase.gsub(/_([a-z])/) { |a| a.upcase }.gsub('_', '')
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


  def build_versions
    @versions = {}
    @deps.each do |dep|
      group = @versions[dep[:group_id]]

      if !group
        group = {}
        @versions[dep[:group_id]] = group
      end

      group[dep[:artifact_id]] = dep[:version]
    end

    @versions
  end

  def output_version_map
    print 'def depVersions = ['

    first_group = true

    @versions.keys.sort.each do |group_id|
      if first_group
        puts
        first_group = false
      else
        puts ','
      end

      print "  '#{group_id}' : ["

      first_version = true

      @versions[group_id].each_pair do |artifact_id, version|
        if first_version
          puts
        else
          puts ','
        end

        first_version = false

        print "    '#{artifact_id}' : '#{version}'"
      end

      puts
      print "  ]"
    end

    puts
    puts ']'
  end

  def output_dependencies
    puts 'dependencies {'
    
    ['compile', 'test', 'runtime', 'provided'].each do |scope| 

      output_dependencies_for_scope(scope)
    end

    puts '}'    
  end

  def output_dependencies_for_scope(scope)
    configuration = translate_dependency_configuration(scope)

    @deps.select { |dep| dep[:scope] == scope }.each do |dep|
      configuration = translate_dependency_configuration(dep[:scope])

      print "  #{configuration} group: '#{dep[:group_id]}', name: '#{dep[:artifact_id]}', " +
                "version: #{version_location(dep)}"

      if dep[:classifier]
        print ", classifier: '#{dep[:classifier]}'"
      end

      puts
    end

    
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
