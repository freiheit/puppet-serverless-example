# A Puppet Control Repository

* [What You Get From This control\-repo](#what-you-get-from-this-control-repo)
* [Copy This Repo Into Your Own Git Server](#copy-this-repo-into-your-own-git-server)
  * [GitLab](#gitlab)
  * [Bitbucket/Stash](#bitbucketstash)
  * [Github](#github)
* [Code Manager Setup](#code-manager-setup)


## What You Get From This control-repo


```
control-repo/
├── data/                                 # Hiera data directory.
│   ├── nodes/                            # Node-specific data goes here.
│   └── common.yaml                       # Common data goes here.
├── manifests/
│   └── site.pp                           # The "main" manifest that contains a default node definition.
├── scripts/
│   ├── code_manager_config_version.rb    # A config_version script for Code Manager.
│   ├── config_version.rb                 # A config_version script for r10k.
│   └── config_version.sh                 # A wrapper that chooses the appropriate config_version script.
├── site-modules/                         # This directory contains site-specific modules and is added to $modulepath.
│   ├── profile/                          # The profile module.
│   └── role/                             # The role module.
├── LICENSE
├── Puppetfile                            # A list of external Puppet modules to deploy with an environment.
├── README.md
├── environment.conf                      # Environment-specific settings. Configures the modulepath and config_version.
└── hiera.yaml                            # Hiera's configuration file. The Hiera hierarchy is defined here.
```

## References

* [site-modules/profile/REFERENCE.md](site-modules/profile/REFERENCE.md)
* [site-modules/role/REFERENCE.md](site-modules/role/REFERENCE.md)
* [REFERENCE.md](REFERENCE.md)
