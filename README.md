# JetBrains License Server for Cloud Foundry  
[![Publish](https://github.com/elgohr/cf-jetbrains-license-server/actions/workflows/publish.yml/badge.svg)](https://github.com/elgohr/cf-jetbrains-license-server/actions/workflows/publish.yml)

This repository contains the license server for JetBrains products, configured to be hosted on [Cloud Foundry](https://github.com/cloudfoundry/).

### Deployment
For deployment on Cloud Foundry the following command.

```bash
cf push jetbrains-license-server \
-o lgohr/cf-jetbrains-license-server \
-m 1024M \
-k 512M
```

Hint: This command assumes, that you are logged in to Cloud Foundry and that the [Docker Support](https://docs.cloudfoundry.org/adminguide/docker.html) is enabled.

### Registration

Sadly Jetbrains License server doesn't provide an official way to configure the License Server with a license.
Nevertheless this deployment can be configured to do so.
In this way the environment variables `USER`, `PASSWORD` and `SERVER_NAME` have to be configured.  
This can be done via Manifest on Deployment, as there is no other way on `cf push` right now.
```yaml
applications:
- name: jetbrains-license-server
  instances: 1
  memory: 1024M
  disk_quota: 512M
  docker:
    image: lgohr/cf-jetbrains-license-server
  env:
    JETBRAINS_USERNAME: {USERNAME_FOR_JETBRAINS}
    JETBRAINS_PASSWORD: {PASSWORD_FOR_JETBRAINS}
    SERVER_NAME: {SERVER_NAME}
```
You could also push the app and configure the environment variables afterwards via `cf set-env`
In the case that you configured it via `cf set-env`, you have to `cf restage` the application afterwards.

| Variable                       | What's that?                                               |
| ------------------------------ | ---------------------------------------------------------- |
| JETBRAINS_USERNAME             | Email or Username from https://account.jetbrains.com/login |
| JETBRAINS_PASSWORD             | Password from https://account.jetbrains.com/login          |
| SERVER_NAME                    | see bellow                                                 |
| HTTPS_PROXYHOST (optional)     | The proxy host (e.g. myCompany.proxy) without protocol     |
| HTTPS_PROXYPORT (optional)     | The proxy port (e.g. 8080)                                 |
| HTTPS_PROXYUSER (optional)     | If the proxy is secured, this is the user                  |
| HTTPS_PROXYPASSWORD (optional) | If the proxy is secured, this is the password              |

> Hint: Please make sure that floating server is enabled for your account (check with sales@jetbrains.com).

When you do the manual registration flow, after logging in, you'll be redirected to https://account.jetbrains.com/server-registration  

This site looks like:

___JetBrains License Server___

_You already have license server set up. Would you like to re-use that or create new one?_

_[O] SERVER_NAME: SERVER_ID_  
_[ ] SERVER_NAME: SERVER_ID_  
_[ ] SERVER_NAME: SERVER_ID_  
_[ ] New Server Registration_  

_[SUBMIT]_

As you can see, the SERVER_NAME must be a unique string.  
Don't try to use the SERVER_ID, because this will change every time you register a new Server!

