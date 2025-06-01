# cern-like-cluster

Physicists who work on the Large Hadron Collider (LHC) at CERN tend to do most of their work on remote machines via ssh which provide access to:
1. a consistent environment;
2. common software;
2. common filesystems such as [eos](https://eos-docs.web.cern.ch/diopside/) (Exabyte storage);
4. and batch computing systems like the [Worldwide LHC Computing Grid](https://home.cern/science/computing/grid) (1.4M cores).

The machines that we remote into are usually just one in a cluster of machines that play different roles and this repository aims to replicate a minimal example of such a cluster. This minimal example contains 3 machines: *server*, *lx01*, and *exec01*. These machines all have the same operating system ([Rocky Linux 9.5](https://rockylinux.org/)), development packages (e.g. `gcc`), [htcondor](https://htcondor.readthedocs.io/en/latest/) for batch computing, [cvmfs](https://cvmfs.readthedocs.io/en/stable/) mounted for common software, and eos mounted to access files stored at CERN. The *server* machine hosts an [NFS share](https://documentation.ubuntu.com/server/how-to/networking/install-nfs/index.html) for the `/home` directory which the other machines mount at `/home` so that the `/home` directory is the same across machines. Finally, each machine is configured differently with htcondor. The *server* machine acts as a manager, `lx01` is where you submit jobs from (an interactive machine), and *exec01* is where jobs get sent to.

<p align="center">
  <img src="docs/minimal_cluster.svg" />
</p>
