feynapps
========

This is a contextualizer used at the [IFCA cloud infrastructure](https://moin.ifca.es/wiki/Cloud) for various tools used in Particle Physics Phenomenology ([FeynHiggs](http://www.feynhiggs.de/), [FeynArts](http://www.feynarts.de/), [FormCalc](http://www.feynarts.de/formcalc/), [LoopTools](http://www.feynarts.de/looptools/)).

For a complete list see [apps.json](blob/master/apps.json).

Application description
-----------------------

Each application is described in a dictionary that follows this schema:


    <application name> : {
        "app_name": "<application name>",
        "dependencies": [ <list of dependencies> ],
        "installer": "<installer script>",
        "versions": {
            "<version name>": {
                "app_version": "<version name>"
            },
            ...
        }
    }

The `dependencies` field contains a list of the names of the applications on which this app depends. The `installer` field contains the name of the script that is used to install the application, relavite to the installers directory. 

Version description may include specific installer or dependencies, that will be used instead of the general one. 

feyninstaller
-------------

The feyninstaller allows users to list available or installed applications, and to install new ones. It is also used for the initial contextualization of the VM. 

