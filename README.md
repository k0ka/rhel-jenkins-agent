# rhel-jenkins-agent
Jenkins inboud agent based on Rocky Linux 8 and podman.

## Running

To run a rootless podman container

    podman run 
      --init
      --user jenkins
      --security-opt label=disable
      --security-opt unmask=ALL
      --device /dev/fuse 
      ghcr.io/k0ka/rocky-jenkins-agent -url http://jenkins-server:port <secret> <agent name>
  `--init` is necessary for correct subprocesses handling (zombie reaping). Other options are used to run container as rootless and bypass any restrictions to run podman inside.
  
Easier but less secure way is to run with `--privileged` flag

    podman run 
      --init
      --privileged 
      ghcr.io/k0ka/rocky-jenkins-agent -url http://jenkins-server:port <secret> <agent name>

Optional environment variables:

* `JENKINS_URL`: url for the Jenkins server, can be used as a replacement to `-url` option, or to set alternate jenkins URL
* `JENKINS_TUNNEL`: (`HOST:PORT`) connect to this agent host and port instead of Jenkins server, assuming this one do route TCP traffic to Jenkins master. Useful when when Jenkins runs behind a load balancer, reverse proxy, etc.
* `JENKINS_SECRET`: agent secret, if not set as an argument
* `JENKINS_AGENT_NAME`: agent name, if not set as an argument
* `JENKINS_AGENT_WORKDIR`: agent work directory, if not set by optional parameter `-workDir`
* `JENKINS_WEB_SOCKET`: `true` if the connection should be made via WebSocket rather than TCP

## See also
* https://github.com/jenkinsci/docker-inbound-agent for base Jenkins inbound agent
* https://www.redhat.com/sysadmin/podman-inside-container on how to run Podman-in-Podman
