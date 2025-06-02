# cern-like-cluster

Physicists who work on the Large Hadron Collider (LHC) at CERN tend to do most of their work on remote machines via ssh which provide access to:
1. a consistent environment;
2. common software;
2. common filesystems such as [eos](https://eos-docs.web.cern.ch/diopside/) (Exabyte storage);
4. and batch computing systems like the [Worldwide LHC Computing Grid](https://home.cern/science/computing/grid) (1.4M cores).

The machines that we remote into are usually just one in a cluster of machines that play different roles and this repository aims to replicate a minimal example of such a cluster. This minimal example contains 3 machines: *server*, *lx01*, and *exec01*. These machines all have the same operating system ([Rocky Linux 9.5](https://rockylinux.org/)), development packages that you expect to find (e.g. `gcc`), [htcondor](https://htcondor.readthedocs.io/en/latest/) for batch computing, [cvmfs](https://cvmfs.readthedocs.io/en/stable/) mounted for common software, and eos mounted to access files stored at CERN. 

The *server* machine hosts an [NFS share](https://documentation.ubuntu.com/server/how-to/networking/install-nfs/index.html) for the `/home` directory which the other machines mount at `/home` so that the `/home` directory is the same across machines. 

The final differences are with respect to the batch computing system (htcondor). In this setup, the intention is that a user will log in to `lx01` (an interactive machine) and do their work there, and if they wish to submit some tasks/jobs to a pool of machines, they can. In this case, that "pool" is just one machine: *exec01*. In htcondor language, this means that *lx01* is configured as an "access point", *exec01* is configured as an "execution point", and *server* is set up as a "central manager" which negotiates between resources and resource requests, i.e. receives jobs from access points and distributes them to execution points.

<p align="center">
  <img src="docs/minimal_cluster.svg" />
</p>

The configuration of these machines is handled automatically with [Ansible](https://docs.ansible.com/). A "playbook" is written which defines the configuration tasks, and this is paired with an "inventory" which defines the machines in the cluster. A playbook contains tasks like installing a particular package with `dnf`, or mounting a drive, and an inventory provides the IP addresses of the machines, and other things like what user Ansible should ssh into the machines with. 

Lastly, there is the issue of where the machines come from in the first place. For a real-world application, one would want to buy physical machines, and also expand the minimal example described above, i.e. have many *exec* machines and possibly more *lx* machines. In my experimentation, I have instead chosen to use virtual machines which I create on my old Dell XPS laptop using [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).

Proxmox VE, as far as I'm concerned, is an operating system that provides native support for virtual machines and makes everything work nicely. Virtual machines can be managed via an online interface, or in the command line, and I use a mixture of both. 

Further details and instructions for creating the virtual machines and configurating them can be found (once added) in the [proxmox directory](proxmox/) and [ansible directory](ansible/) of this repository.