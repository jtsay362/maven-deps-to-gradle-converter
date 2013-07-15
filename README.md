maven-deps-to-gradle-converter
==============================

Converts maven dependency output to a gradle build file excerpt.

Takes the top section of "mvn -X compile" output like this:

    [DEBUG]    commons-codec:commons-codec:jar:1.7:compile
    [DEBUG]    commons-collections:commons-collections:jar:3.2.1:compile
    [DEBUG]    commons-beanutils:commons-beanutils:jar:1.8.3:compile
    [DEBUG]       commons-logging:commons-logging:jar:1.1.1:compile
    [DEBUG]    commons-validator:commons-validator:jar:1.3.1:compile
    [DEBUG]       commons-digester:commons-digester:jar:1.6:compile
    [DEBUG]          xml-apis:xml-apis:jar:1.0.b2:compile
    ...
    [DEBUG]    org.specs2:specs2_2.9.3:jar:1.12.4.1:test
    [DEBUG]       org.specs2:specs2-scalaz-core_2.9.3:jar:6.0.1:test
    [DEBUG]    org.scalatest:scalatest_2.9.3:jar:1.9.1:test


And turns it into:

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

    def compileDepVersions = [
      'commons-beanutils' : [
       'commons-beanutils' : [version: '1.8.3']
      ],
      'commons-codec' : [
       'commons-codec' : [version: '1.7']
      ],
      'commons-collections' : [
       'commons-collections' : [version: '3.2.1']
      ],
      ...
    ]

    def testDepVersions = [
      'org.scalatest' : [
       'scalatest_2.9.3' : [version: '1.9.1']
      ],
      'org.specs2' : [
       'specs2_2.9.3' : [version: '1.12.4.1']
      ],
      ...
    ]

    addDependencies('compile', compileDepInfo)
    addDependencies('testCompile', testDepInfo)
    addDependencies('runtime', runtimeDepInfo)
    addDependencies('providedCompile', providedDepInfo)

To run the example:

    lib/dep_converter.rb test/data/deps.txt

You can create your own input file by running "mvn -X compile", selecting the top dependency section, and saving it to
a file.

Feedback and improvements welcome!
