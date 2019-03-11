package main

import (
	"github.com/dcvan24/manuka/overlay2"
	"github.com/docker/docker/pkg/reexec"
	"github.com/docker/go-plugins-helpers/graphdriver/shim"
)

func main() {
	if reexec.Init() {
		return
	}
	h := shim.NewHandlerFromGraphDriver(overlay2.Init)
	h.ServeUnix("manuka", 0)
}
