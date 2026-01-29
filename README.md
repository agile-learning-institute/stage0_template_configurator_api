<!-- TEMPLATE_SPECIFIC_START -->
<!-- This section will be removed during template processing -->
## This is a Stage0 Merge Template
This repository is a template to create a custom configurator_api for your system. See [Template Guide](https://github.com/agile-learning-institute/stage0_runbook_merge/blob/main/TEMPLATE_GUIDE.md) for information about stage0 merge templates. See the [Processing Instructions](./.stage0_template/process.yaml) for details about this template, and [Test Specifications](./.stage0_template/Specifications/) for sample context data required.

Template Commands
```sh
# Test the Template using test_expected output
# Creates ~/tmp folders 
make test

## Clean up temp files from testing
## Removes tmp folders
make clean

## Process this merge template using the provided context path
## NOTE: Destructive action, will remove .stage0_template 
make merge <context path>
```

<!-- TEMPLATE_SPECIFIC_END -->
# {{info.name}} Mongodb Configurator API

This repo contains the MongodDB Database Configurations for the {{info.name}} system. You can use the following commands to test, edit, and package these configurations. Note that the configuration files are just yaml files in the configurator folder - after you have made and tested changes you still need to commit your changes to a branch, and merge a PR to make them available to the other developers. 

## Prerequisites
- {{info.name}} [Developers Edition]({{org.git_host}}/{{org.git_org}}/{{info.slug}}/blob/main/CONTRIBUTING.md)

## Developer Commands
```sh
## Run the dev runtime to edit the configurations.
make dev

## Build the container for deployment
make container

## Run the packaged configuration. (Read Only configurations)
make deploy

## Open the browser for running containers
make open

## Shut down the containers
make down

## Generate Test Data See below
make test_data COLLECTION VERSION
```

## Test Data
- Test data is just json files in the [test_data](./configurator/test_data/) folder. You can use an LLM tool to generate test data from schema's. 

## Workflow
- First, create a feature branch for your work
- run ``make dev`` and use the UI to update the configurations
- When you're done making edits:
    - Check that "Drop Database" and then "Configure Database" returns all green.
    - Make sure ``make container`` runs without error.
    - Use ``make deploy`` to review that the changes made it into the container.
    - Use you source-control viewer to review source yaml changes to make sure no un-expected files were updated.
    - Commit and Push your changes on the new branch
    - Open a PR and request a review
    - When the PR is merged to main, ci will publish an updated container for use by the team.
    - After the PR is merged the branch is deleted - ``git checkout main`` and ``git pull``.
    - Don't forget to ``make down`` to shut down the containers and free the ports.

