# JetBrains License Server for Cloud Foundry

This repository contains the license server for JetBrains products, configured to be hosted on [Cloud Foundry](https://github.com/cloudfoundry/).

### Deployment
For deployment on Cloud Foundry the following command.

```bash
cf push jetbrains-license-server -o lgohr/cf-jetbrains-license-server -m 1024M -k 512M
```

Hint: This command assumes, that you are logged in to Cloud Foundry and that the [Docker Support](https://docs.cloudfoundry.org/adminguide/docker.html) is enabled.

