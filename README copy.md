# mongodb_data

This repo contains the MongodDB Database Configurations for the Creator Dashboard system. You can use the following commands to test, edit, and package these configurations. Note that the configuration files are just yaml files in the configurator folder - after you have made and tested changes you still need to commit your changes to a branch, and merge a PR to make them available to the other developers. 

## Prerequisites
- Creator Dashboard [Developers Edition](https://github.com/agile-crafts-people/CreatorDashboard/blob/main/DeveloperEdition/README.md)

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
- Test data is just json files in the [test_data](./configurator/test_data/) folder. To use an LLM tool to generate test data use the 
```sh
make test_data COLLECTION=<name> VERSION=<version>
``` 
command, which will get the latest schema using curl, and execute a LLM Task to create test data. 

**Before** running this script, you should:
- Update `./tasks/TestDataInstructions.md` with special instructions about what kind of test data you want.
- Connect to the Dev VPN for backing LLM services, **or** use a custom backing LLM Host/Service:

```sh
export LLM_PROVIDER=ollama                  # Options: ollama, openai, azure, null
export LLM_MODEL=qwen3-coder:30b            # Model name for your provider
export LLM_BASE_URL=http://localhost:11434  # Your LLM service endpoint
export LLM_API_KEY=your_api_key             # Optional, for OpenAI/Azure
```

Then run:
```sh
make test_data COLLECTION=User VERSION=0.1.0.0 
```

## Workflow
- First, create a new branch for this repo - named for your intent
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

