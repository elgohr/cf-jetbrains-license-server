workflow "Publish" {
  resolves = [
    "logout",
  ]
  on = "push"
}

action "test" {
  uses = "actions/docker/cli@master"
  args = "build ."
}

action "master" {
  needs = "test"
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "login" {
  needs = "master"
  uses = "actions/docker/login@master"
  secrets = [
    "DOCKER_USERNAME",
    "DOCKER_PASSWORD",
  ]
  env = {
    DOCKER_REGISTRY_URL = "docker.pkg.github.com"
  }
}

action "publish" {
  uses = "elgohr/Publish-Docker-Github-Action@master"
  args = "docker.pkg.github.com/elgohr/cf-jetbrains-license-server/cf-jetbrains-license-server"
  needs = ["login"]
}

action "logout" {
  uses = "actions/docker/cli@master"
  args = "logout"
  needs = ["publish"]
}
