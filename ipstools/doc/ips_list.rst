.. ipstools documentation for ips_list.yml files

IPs and RTL file lists (`ips_list.yml` and `rtl_list.yml`)
==========================================================

`ips_list.yml` and basic IP flow
********************************

The `ipstools` flow is based on a relatively simple list of "IPs", which are described primarily in a file called `ips_list.yml` located in the root of the repository.

An `ips_list.yml` contains a list of all IPs necessary to build a design::
      
    riscv:
      commit: tags/pulpino-final
      alternatives: [riscv, zero-riscy]
      domain: [cluster]
    zero-riscy:
      commit: tags/pulpino-final
      alternatives: [riscv, zero-riscy]
      domain: [cluster]
    apb/apb_spi_master:
      commit: 62b10440
      domain: [soc]

Each IP is referenced by its name (which is typically also part of its path).
The information collected in the `ips_list.yml` can be used by a `generator script` (included in the main repository) to download all the IPs in their correct location and generate the related scripts

The following is the list of keys allowed in an `ips_list.yml` file:

- `commit`: this indicates the specific version of the IP in its Git repository. It can be a branch (e.g. `master`), although -- to maintain consistency and reference a well-defined version of an IP -- it is highly preferable to indicate a tag or a commit hash. In the latter case, some care must be taken so that, when the IP is modified, the changes are effectively committed to the correct IP.
- `domain`: this optional key is a list used in complex designs to perform multi-stage synthesis.
- `alternatives`: this optional key is used in the case multiple IPs are interchangeable. Each of the interchangeable IPs is tagged with the same `alternatives` clause.

`rtl_list.yml` and local HDL script generation
**********************************************

To support script generation similar to that of IPs also for HDL directly included in the repository, `src_files.yml` files can be deployed also without the necessity of a separate Git repository.
The `rtl_list.yml` is meant to indicate where to found those local `src_files.yml` files.
It follows a similar syntax to that of `ips_list.yml`, but does not support the `commit` and `alternatives` keys::

    cluster:
      domain: [cluster]
    soc:
      domain: [soc]
    tb:
      domain: [soc, cluster]
      path: ../tb

By default, the "IP name" is also used as an indication of the path, relative to the RTL directory that is specified in the generator script (e.g., `rtl` in PULPino). A `path` key, which is also relative to the RTL directory, can be used to override this behavior.

Hierarchical IP flow
********************

If the generator script is set up appropriately, the `ipstools` also support a hierarchical IP flow in which each IP can contain its own `ips_list.yml` indicating IP dependencies.
This can have several advantages, although it requires user interaction to resolve version conflicts when they arise.
The `ips_list.yml` files within each IP (and, if one wants to do local simulations, their `rtl_list.yml` files) work exactly like in the "main"
repositories.
The hierarchical flow is started by setting to True the value of two parameters when creating the IP database (`build_deps_tree` and `resolve_deps_conflicts` -- both default to False).

