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

And turns it into:


def depVersions = [
  'commons-codec' : [
    'commons-codec' : '1.7'
  ],
  'commons-collections' : [
    'commons-collections' : '3.2.1'
  ],
  ...
]

dependencies {
  compile group: 'commons-codec', name: 'commons-codec', version: depVersions['commons-codec']['commons-codec']
  compile group: 'commons-collections', name: 'commons-collections', version: depVersions['commons-collections']['commons-collections']
  ...
}