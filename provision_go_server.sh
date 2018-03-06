#!/bin/bash

  # Add GoCD official
  echo "deb https://download.gocd.io /" | tee /etc/apt/sources.list.d/gocd.list
  curl -# https://download.gocd.io/GOCD-GPG-KEY.asc | apt-key add -
  apt-get update
  # Install and set up GoCD server, agents and requirements
  apt-get install -y openjdk-8-jre git
  apt-get install -y go-server go-agent
  # Add more GoCD agents
  if [ ! -f /etc/init.d/go-agent-2 ]; then
    echo "Installing agent 2"
    cp /etc/init.d/go-agent /etc/init.d/go-agent-2
    sed -i 's/# Provides: go-agent$/# Provides: go-agent-2/g' /etc/init.d/go-agent-2
    ln -s /usr/share/go-agent /usr/share/go-agent-2
    cp -p /etc/default/go-agent /etc/default/go-agent-2
    mkdir /var/{lib,log}/go-agent-2
    chown go:go /var/{lib,log}/go-agent-2

    update-rc.d go-agent-2 defaults
  fi

  if [ ! -f /etc/init.d/go-agent-3 ]; then
    echo "Installing agent 3"
    cp /etc/init.d/go-agent /etc/init.d/go-agent-3
    sed -i 's/# Provides: go-agent$/# Provides: go-agent-3/g' /etc/init.d/go-agent-3
    ln -s /usr/share/go-agent /usr/share/go-agent-3
    cp -p /etc/default/go-agent /etc/default/go-agent-3
    mkdir /var/{lib,log}/go-agent-3
    chown go:go /var/{lib,log}/go-agent-3

    update-rc.d go-agent-3 defaults
  fi

  # Lower the polling interval - WAY too low for a real server, don't do this!
  /bin/echo "Lowering polling interval - remove this for production server"
  /bin/bash /vagrant/update_go-server.sh

  # Start the server
  /bin/echo "Starting GoCD Server and Agents"
  /etc/init.d/go-server start

  /etc/init.d/go-agent start
  /etc/init.d/go-agent-2 start
  /etc/init.d/go-agent-3 start

  curl -sL https://deb.nodesource.com/setup_6.x | bash -
  apt-get install -y nodejs
  echo "alias node='nodejs'" > /var/go/.bashrc
  # Remove packages no longer needed
  apt-get -y autoremove
