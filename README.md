# rocky-jenkins-agent
Jenkins inboud agent based on Rocky Linux 8 and podman.

## Running

To run a podman container

    podman run --init https://ghcr.io/k0ka/rocky-jenkins-agent -url http://jenkins-server:port <secret> <agent name>
  Note: `--init` is necessary for correct subprocesses handling (zombie reaping)

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
