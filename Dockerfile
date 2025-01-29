FROM rockylinux/rockylinux 

ARG VERSION=3283.v92c105e0f819

ENV \
	SUMMARY="Platform for running Jenkins inbound agent with Podman-in-Podmain" \
	DESCRIPTION="This is a base image for podman, which includes JDK and podman itself. It can be used to run rootless podman commands inside container."

LABEL maintainer="admin@idwrx.com" \
	summary="${SUMMARY}" \
	description="${DESCRIPTION}" \
	name="idwrx/rocky-jenkins-agent"

RUN \
	dnf -y update \
	&& rpm --restore shadow-utils 2>/dev/null \
	&& dnf -y install podman fuse-overlayfs crun --exclude container-selinux \
	&& dnf -y install java-11-openjdk-headless \
	&& dnf -y install git podman-docker \
	&& rm -rf /var/cache /var/log/dnf* /var/log/yum.* \
	&& useradd jenkins \
	&& mkdir /home/jenkins/.ssh \
	&& chown -R jenkins:jenkins /home/jenkins \
	&& echo jenkins:100000:655360 >/etc/subuid \
	&& echo jenkins:100000:655360 >/etc/subgid 

# get jenkins agent - from https://github.com/jenkinsci/docker-agent
RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

# from https://www.redhat.com/sysadmin/podman-inside-container
COPY ./containers.conf /etc/containers/containers.conf

# from https://github.com/jenkinsci/docker-ssh-agent/blob/master/setup-sshd
COPY ./entrypoint.sh /entrypoint.sh

# chmod containers.conf and adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf \
	&& sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf \
	&& mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers \
	&& touch /var/lib/shared/overlay-images/images.lock \
	&& touch /var/lib/shared/overlay-layers/layers.lock \
	&& touch /var/lib/shared/vfs-images/images.lock \
	&& touch /var/lib/shared/vfs-layers/layers.lock \
	&& touch /etc/containers/nodocker

RUN chmod 755 /entrypoint.sh
USER jenkins

ENTRYPOINT ["/entrypoint.sh"]
