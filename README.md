This vagrant project will install a generic DPUK XNAT instance to a local
virtualbox VM.  A generic DPUK XNAT install consists of multiple constituent parts:

* java7
* tomcat7
* postgres 9.3
* XNAT 1.6.5 (dpuk node branch)
* DPUK modules

### Prerequisites

To create an XNAT 1.6.5 virtual machine, you'll need the following software:

* [Git](https://git-scm.com)
* [Vagrant](https://www.vagrantup.com)
* [VirtualBox](https://www.virtualbox.org)

### Installation

Once you have the prerequisites above, it should be straightforward to create your new test DPUK Node instance:

At the command line:

```bash
git clone https://github.com/mattsouth/dpuk_vagrant
cd dpuk_vagrant
```
Review the settings in vars.sh, particularly TODO:

```bash
vagrant up
```

After running 'vagrant up' you should be able to see a dpuk branded version of
xnat on http://192.168.50.50.  The default admin credentials are admin/admin
The first time you login you'll need to configure three things:
 * set the site description - we suggest DPUK-[SITE], e.g. DPUK-OXFORD
 * configure data freeze
 * register the dpuk datatypes

### Notes

This project is based on the [reference XNAT 1.6.5 vagrant project](https://bitbucket.org/nrg/xnat_vagrant_1_6dev).
