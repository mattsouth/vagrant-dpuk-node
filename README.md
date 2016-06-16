## NOTE: SQLONLY branch - SQL install when TOMCAT and POSTGRESQL are separated

This vagrant project will help setup a DPUK XNAT Node instance to a local
virtualbox VM.  A DPUK XNAT Node install includes multiple constituent parts:

* java7
* tomcat7
* postgres 9.3
* Postfix
* XNAT 1.6.5 (dpuk node branch)
* DPUK modules

### Prerequisites

To create an XNAT 1.6.5 virtual machine, you'll need the following software:

* [Git](https://git-scm.com)
* [Vagrant](https://www.vagrantup.com)
* [VirtualBox](https://www.virtualbox.org)

### Installation

Once you have the prerequisites above, it should be straightforward to setup your own test DPUK Node instance:

At the command line:

```bash
git clone https://github.com/mattsouth/vagrant-dpuk-node
cd vagrant-dpuk-node
```

This project will create a virtual machine on IP address 192.168.50.50, which expects to be mapped to http://xnat.dpukdev.org. You must set this mapping up yourself (i.e. in /etc/hosts) or change it to one
that suits you better in vars.sh.  By default postfix is setup to send mail but this may not work in a
university network.  You can configure an alternative smtp server in the services.properties file.
You will need to change the default admin email address to your own in the services.properties file.
Have a quick review of the files and then run:

```bash
vagrant up
```
It should take approx 5 mins to setup the box (dependent on your network connection and the responsiveness of the various repositories involved in the build) during which time you'll see lots of System output from the install process.

After running 'vagrant up' you should be able to see a dpuk branded version of
xnat on http://xnat.dpukdev.org (or whatever you've configured).  The default admin credentials are admin/admin
The first time you login you'll need to configure three things:
 * set the site description - we suggest DPUK-[SITE], e.g. DPUK-OXFORD
 * configure the data freeze functionality (see freeze folder for default text)
 * register the dpuk datatypes
See https://info.dpuk.org/testing/post-install-steps for further instructions

### Notes

This project is based on the [reference XNAT 1.6.5 vagrant project](https://bitbucket.org/nrg/xnat_vagrant_1_6dev).

### KVM

Several partner institutions have used KVM and not Virtualbox.
