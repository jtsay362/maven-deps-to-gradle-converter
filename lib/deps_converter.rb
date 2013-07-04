#!/usr/bin/env ruby

class DepsConverter
  SCOPES = ['compile', 'test', 'runtime', 'provided']

  def initialize
    @debug_enabled = false
  end

  def convert(deps_filename)
    build_deps(deps_filename)

    debug @deps

    build_versions

    debug @versions

    output_version_maps

    puts

    output_dependencies

  end

  private

  def group_location(dep)
    "#{dep[:scope]}DepVersions['#{dep[:group_id]}']"
  end

  def version_location(dep)
    "#{group_location(dep)}['#{dep[:artifact_id]}']"

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
      scope = @versions[dep[:scope]]

      if !scope
        scope = {}
        @versions[dep[:scope]] = scope
      end

      group = scope[dep[:group_id]]

      if !group
        group = {}
        scope[dep[:group_id]] = group
      end

      group[dep[:artifact_id]] = dep
    end

    @versions
  end

  def output_version_maps
    SCOPES.each do |scope|
      output_version_map_for_scope(scope)
      puts
    end
  end

  def output_version_map_for_scope(scope)
    print "def #{scope}DepVersions = ["

    first_group = true

    versions_for_scope = @versions[scope]

    versions_for_scope.keys.sort.each do |group_id|
      if first_group
        puts
        first_group = false
      else
        puts ','
      end

      print "  '#{group_id}' : ["

      first_version = true

      versions_for_scope[group_id].each_pair do |artifact_id, dep|
        if first_version
          puts
        else
          puts ','
        end

        first_version = false

        print "    '#{artifact_id}' : '#{dep[:version]}'"
      end

      puts
      print '  ]'
    end

    puts
    puts ']'
  end

  def output_dependencies
    puts 'dependencies {'
    
    SCOPES.each do |scope|
      output_dependencies_for_scope(scope)
    end

    puts '}'    
  end

  def output_dependencies_for_scope(scope)
    configuration = translate_dependency_configuration(scope)

    versions_for_scope = @versions[scope]

    versions_for_scope.keys.sort.each do |group_id|
      artifacts_for_group = versions_for_scope[group_id]

      artifacts_for_group.keys.sort.each do |artifact_id|
        dep = artifacts_for_group[artifact_id]

        print "  #{configuration} group: '#{group_id}', name: '#{artifact_id}', " +
                  "version: #{version_location(dep)}"

        if dep[:classifier]
          print ", classifier: '#{dep[:classifier]}'"
        end

        puts
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
