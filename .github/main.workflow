workflow "Publish Master" {
  on = "push"
  resolves = ["logout-master"]
}

workflow "Publish Tags" {
  on = "push"
  resolves = ["logout-tags"]
}

action "test" {
  uses = "actions/docker/cli@master"
  args = "build ."
}

action "master" {
  needs = ["test"]
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "tags" {
  needs = ["test"]
  uses = "actions/bin/filter@master"
  args = "tag"
}

action "login-master" {
  needs = ["master"]
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "publish-master" {
  uses = "elgohr/Publish-Docker-Github-Action@master"
  args = "lgohr/cf-jetbrains-license-server"
  needs = ["login-master"]
}

action "logout-master" {
  uses = "actions/docker/cli@master"
  args = "logout"
  needs = ["publish-master"]
}

action "login-tags" {
  needs = ["tags"]
  uses = "actions/docker/login@master"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "publish-tags" {
  uses = "elgohr/Publish-Docker-Github-Action@master"
  args = "lgohr/cf-jetbrains-license-server"
  needs = ["login-tags"]
}

action "logout-tags" {
  uses = "actions/docker/cli@master"
  args = "logout"
  needs = ["publish-tags"]
}

