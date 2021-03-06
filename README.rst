Jenkins Configuration
=====================

A collection of groovy scripts for automating the configuration of Jenkins and
third party plugins

Tools like the Jenkins Job DSL allow you to programmatically create jobs and other
resources. However, the configuration of Jenkins itself is still a manual process and is error prone.
These scripts can be used to create a reproducible and testable Jenkins instance, complete with
plugins installed and is ready to use.

Setup
-----

System Requirements
~~~~~~~~~~~~~~~~~~~

Working on this repository requires that both Docker and Gradle are installed.

Setup
~~~~~

Install python dependencies for acceptance testing (on a Jenkins instance
running within a Docker container), as well as various Groovy helper utilities.

.. code:: bash

    make requirements

Before building the docker container, you should download Jenkins plugins (with
dependencies). By default, the plugins specified in test_data/plugins.yml will
be installed. However, if you wish to use another file, set the environment
variable $PLUGIN_CONFIG to point to the YAML file you wish to use.

.. code:: bash

    make plugins

Configuring Jenkins
-------------------

Jenkins will run Groovy code placed in $JENKINS_HOME/init.groovy.d on each boot.


Tips/Tricks
~~~~~~~~~~~

Unlike the Jenkins Script Console, Jenkins-related libraries are not auto-imported,
so make sure you import the following into your scripts:

.. code:: groovy

    import jenkins.*
    import jenkins.model.*
    import hudson.*
    import hudson.model.*

Scripts are run in lexicographical order. Use a numerical prefix for scripts that
must be run in a particular order. The following order is suggested for scripts:

    - 1<scriptName> : bootstrapping scripts, such as making helper jars available
    - 2<scriptName> : verification scripts, used to check the system before configuration
    - 3<scriptName> : main (Jenkins core) configuration scripts
    - 4<scriptName> : plugin configuration scripts
    - ...
    - 9<scriptName> : scripts to run at the end of the configuration process (i.e. putting into quiet mode or testing a configuration

Groovy Dependencies:
~~~~~~~~~~~~~~~~~~~~

In order to use libraries outside of the Groovy standard library, you must first run
src/main/groovy/1_add_jars_to_classpath.groovy. This will allow you to make use of
the Groovy Grape_ system in subsequent scripts for importing external libraries. For
example, if you wanted to make use of the Snake Yaml library:

.. code:: groovy

    @Grab(group='org.yaml', module='snakeyaml', version='1.17')
    import org.yaml.snakeyaml.Yaml

.. _Grape: http://docs.groovy-lang.org/latest/html/documentation/grape.html

Testing
-------

Linting
~~~~~~~

Run codenarc_ to lint the groovy code in src/main/groovy and src/test/groovy

.. code:: bash

    make quality

Linting reports can be viewed in build/reports/codenarc/main.html

.. _Codenarc: http://codenarc.sourceforge.net/

Acceptance Testing
~~~~~~~~~~~~~~~~~~

Build a Docker image with Jenkins and the scripts from this repo installed

.. code:: bash
    
    make build

Run the image in the background

.. code:: bash
    
    make run

Test that Jenkins has initialized correctly

.. code:: bash
    
    make healthcheck

Test the configuration of a running Jenkins instance

.. code:: bash

    make e2e

