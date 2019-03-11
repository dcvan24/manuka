Manuka: A Docker GraphDriver Development Toolkit
==============================

### Overview
The toolkit serves as a base environment for [Docker graphdriver plugin](https://docs.docker.com/engine/extend/plugins_graphdriver/) development, since this feature is still experimental and the guidance for developing the plugin is lacking. The toolkit runs the standard `overlay2` graph driver pulled from the [Moby](https://github.com/moby/moby) code base as a Docker graphdriver plugin and renames it as *Manuka*. 


### Pre-requisites
The pre-requisites are listed below but the requirments are not tight. 
 
- Linux amd64 (preferably Ubuntu 18.10)
- Docker 18.09 (The plugin interface has changed a little bit since 18)
- Go 1.12 (> 1.10 and < 1.19)

A [Vagrant](./vagrant) environment is provided here for quickstart, which pre-installs all the pre-requisites in the VM. To launch the environment, make sure you have [VirtualBox]() and [Vagrant]() properly installed on your machine:

```bash
$ vagrant up && vagrant ssh
```

If everything works as expected, you should log into a Ubuntu 18.10 VM running locally on your machine via SSH. To clean up the environment, 

```bash 
$ vagrant destroy
```

If you want to initialize the dev environment on a Linux box, simply runs the [build.sh](./vagrant/build.sh) script on the box (assuming it runs Ubuntu 18.10).

### Go environment setup

First of all, the environmental variable `$GOPATH` needs to set properly, default to `${HOME}/go`. Go requires all the go code developed under `$GOPATH`, so the toolkit needs to be placed under `$GOPATH`. A workaround to avoid diving deep into the `$GOPATH` is to create a soft link of the code base elsewhere. To fetch the toolkit into `$GOPATH`.

```bash
$ go get dcvan24/manuka
```


### Build and run the plugin

The toolkit runs the plugin in compliance with the [Docker Plugin API v1](https://docs.docker.com/engine/extend/plugin_api/), in which the plugin is discovered by the daemon as a process listening on a UNIX sokcet located under `/var/run/docker/plugins`. With [Docker Plugin API v2](https://docs.docker.com/engine/extend/) wherein the plugin is containerized, the `MergedDir` created in the plugin cannot be reflected on the host, causing errors when containers being started. The problem is suspected related to the misconfiguration of the mountpoint in the plugin but not yet addressed. 

To build the plugin, compile the plugin into a binary using `go`

```console
$ go build main.go && ls 
Dockerfile  README.md  main  main.go  overlay2  vagrant
```	

After the build, you will see the `main` file as an executable. Execute `main` using `sudo` to start the graphdriver plugin

```console
$ sudo ./main
```

You will see the UNIX socket the graphdriver is listening on under `/var/run/docker/plugins`

```console
$ sudo ls /var/run/docker/plugins
manuka.sock  runtime-root
```

Then launch the Docker daemon and let it use the graphdriver plugin. Note that the daemon is able to discover the plugin automatically under `/var/run/docker/plugins`. To refer to the plugin, simply use the name of the socket, i.e. `manuka` in this case. Since the feature is still experimental, you need to specify `--experimental` to turn on the experimental mode of the Docker daemon in order to apply the graphdriver plugin.

```console
$ dockerd -D --experimental -s manuka
```

Alternatively, you can specify the options in `/etc/docker/daemon.json` and start the daemon using SystemD (if the Docker daemon is managed in SystemD).

```console
$ cat | sudo tee /etc/docker/daemon.json <<-EOF
{
    "experimental": true,
    "storage-driver": "manuka"
}
EOF
$ sudo systemtcl restart docker
```



