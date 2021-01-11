# Nocapp

[![N|Solid](https://qa-static-content.s3-ap-southeast-1.amazonaws.com/email/logo_email_v6.png)](https://development.test-internal.com)

[![Setup Deploy](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Nocapp is a system level grobally, identify app powered by myapp devops team.

  - Capable of git integration
  - System setup
  - Build
  - Dockerize 

### Tech

* [Java-11] 
* [Node-8]
* [php 7.2]


And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.
### Prerequisite
if your github password contains sepcial char like $/@# etc then generate a token from below link 
https://github.com/settings/tokens
use that token in installation guild block 1 nocapp-dev-setup/build_env/git.sh
### Installation

1. Clone repo and initlize nocapp .

    ```sh
    $ git clone https://github.com/OitoLabs/nocapp-dev-setup.git
    $ cd nocapp-dev-setup
    $ ./init.sh 
    $ Change username and password/token(incase password contains sepcial char) in nocapp-dev-setup/build_env/git.sh
      if any special char use https://github.com/settings/tokens to generate git token and use that as password in nocapp-dev-setup/build_env/git.sh
    ```
2. One Time Setup Commands .

    ```sh
    $ nocapp setup server
    $ nocapp setup es raw
    ```
3. Regular Used Commands .

    ```sh
    add/remove service names from file nocapp-dev-setup/service.txt
    $ nocapp git sync
    $ nocapp setup config 
    $ nocapp setup db
    $ nocapp code build
    $ nocapp dev rebuild
    $ nocapp dev start mode1
    $ nocapp host disable 
    $ nocapp dev status
    ```    
4. Pimcore Used Commands .

    ```sh
    $ nocapp setup pimcore
    $ nocapp dev start pimcore
    $ nocapp dev stop pimcore 
    ```    
### help

Nocapp help commands are below.

Note: ServiceName will be short name without -service

| Command | Parameter | Description |
| ------ | ------ | ------ |
| **nocapp dev status** | Blank/Mode/ServiceName | gives status of services |
| **nocapp dev start**  | Blank/Mode/ServiceName debug <debug-port> | start container of services |
| **nocapp dev stop** | Blank/Mode/ServiceName | stop container of services |
| **nocapp dev rebuild** | Blank/Mode/ServiceName | build docker image of services |
| **nocapp dev restart** | Blank/Mode/ServiceName | recreate container of services |
| **nocapp dev remove** | Blank/Mode/ServiceName | remove stopped conatiners from system |
| **nocapp dev variable** | ServiceName | shows variable applied to container at run time |
| **nocapp dev resource** |  | shows resource utilization stats of running conatiner |
| **nocapp dev log/logs** | ServiceName & --since 30s | shows container logs |
| **nocapp dev clean** | | purge unwanted containers |
| **nocapp host disable** | | stop and disable system unwanted services |
| **nocapp dev location** | | shows working directory of setup |
| **nocapp docker in** | ServiceName | enters inside container |
| **nocapp mysql in** | ServiceName | enters inside mysql server |
| **nocapp git sync** | Blank/ServiceName Branchname | Fetch latest git changes |
| **nocapp code build** | Blank/ServiceName | does code build of services |
| **nocapp setup config** |  | sets override values to flase in application-dev.yml |
| **nocapp setup es** | empty/data| pushes es data into elastic search |
| **nocapp setup db** |  Blank/ServiceName  | setup databases |
| **nocapp import dumps** |  ServiceName  | import qa db dumps |
| **nocapp db sync** |  Blank/ServiceName  | sync recently added databases schemas |
| **nocapp setup server** |  | install all prerequisite for app |
| **nocapp setup pimcore** |  | install all prerequisite for pimcore |
| **nocapp update app** |  | fetch latest changes for app |


### Compatibility
1. ubuntu-16
2. ubuntu-18
2. ubuntu-20

### Verify
Verify the deployment by navigating to your server address in your preferred browser.

Buyer: 
```sh
https://development.test-internal.com/
```

Seller: 
```sh
https://development.test-internal.com/seller
```

### Todos

 - Keep syncing repo for latest update of nocapp

