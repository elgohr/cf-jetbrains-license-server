# JetBrains License Server for Cloud Foundry

This repo contains the license server for JetBrains products, configured to be hosted on [Cloud Foundry](https://github.com/cloudfoundry/).

### Installation
For Deployment on CF you simply have to execute the following command in the pulled [Github Repo](https://github.com/elgohr/cf-jetbrains-license-server).

```bash
cf push -o lgohr/cf-jetbrains-license-server
```

### Configuration
For security reasons I would recommend you to configure an own access-config.json in the Dockerfile.
The URL can be configured by overwriting the environment parameter ACCESS_CONFIG_URL.
See [Documentation](https://www.jetbrains.com/help/license_server/configuring_user_restrictions.html) for more information.
