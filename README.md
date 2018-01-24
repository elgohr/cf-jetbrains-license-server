# JetBrains License Server for Cloud Foundry

This repo contains the license server for JetBrains products, configured to be hosted on [Cloud Foundry](https://github.com/cloudfoundry/).

### Installation
For Deployment on CF you simply have to execute the following command in the pulled [Github Repo](https://github.com/elgohr/cf-jetbrains-license-server).

```bash
cf push jetbrains-license-server -o lgohr/cf-jetbrains-license-server -m 1024M -k 512M
```


