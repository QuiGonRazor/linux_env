# Linux environment setup

![GitHub repo size](https://img.shields.io/github/repo-size/QuiGonRazor/linux_env?style=flat-square)

This project aims to collect in a single place a quick to use environment setup.
If you are under a WSL system it install some useful tools.

## Installing environment

In order to install the environment you can use one of following commands.

This first command will let you to source the tools directly from the folder where you cloned the repo:
```
install_env.sh -r
```

Meanwhile, below command will install the tools inside your `/usr/local/bin` folder:
```
install_env.sh -b
```

Furthermore you can choose to set up some extra aliases, like Git's.

Common aliases will be write into this path: `/home/user/.user_configs` 
The tool will try to source it inside your `.bashrc` file

## Using the tool

Below some examples:

To install your tools inside `/usr/local/bin` folder and setup git aliases

```
install_env.sh -r -g -u git_username -e git_email
```

That's all folks!

> Enjoy and contribute!!!!

