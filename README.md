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

    def compileDepVersions = [
      'commons-beanutils' : [
       'commons-beanutils' : '1.8.3'
      ],
      'commons-codec' : [
       'commons-codec' : '1.7'
      ],
      'commons-collections' : [
       'commons-collections' : '3.2.1'
      ],
      ...
    ]

    def testDepVersions = [
      'org.scalatest' : [
       'scalatest_2.9.3' : '1.9.1'
      ],
      'org.specs2' : [
       'specs2_2.9.3' : '1.12.4.1'
      ],
      ...
    ]

    dependencies {
      compile group: 'commons-beanutils', name: 'commons-beanutils', version: compileDepVersions['commons-beanutils']['commons-beanutils']

      compile group: 'commons-codec', name: 'commons-codec', version: compileDepVersions['commons-codec']['commons-codec']

      compile group: 'commons-collections', name: 'commons-collections', version: compileDepVersions['commons-collections']['commons-collections']

      ...

      testCompile group: 'org.scalatest', name: 'scalatest_2.9.3', version: testDepVersions['org.scalatest']['scalatest_2.9.3']

      testCompile group: 'org.specs2', name: 'specs2_2.9.3', version: testDepVersions['org.specs2']['specs2_2.9.3']
    }

To run the example:

    lib/dep_converter.rb test/data/deps.txt

You can create your own input file by running "mvn -X compile", selecting the top dependency section, and saving it to
a file.

Feedback and improvements welcome!
