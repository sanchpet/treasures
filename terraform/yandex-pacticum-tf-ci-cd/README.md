# terraform-ci-cd-example-yandex-cloud

Simple example on how to set up basic CI/CD repository for Terraform with Yandex Cloud and state lock

- [terraform-ci-cd-example-yandex-cloud](#terraform-ci-cd-example-yandex-cloud)
  - [Configuration description](#configuration-description)
    - [`yc-terraform-state-lock.tf`](#yc-terraform-state-locktf)
    - [`main.tf`](#maintf)
  - [Set up backend in S3 with state lock](#set-up-backend-in-s3-with-state-lock)
  - [Set up CI/CD in GitLab](#set-up-cicd-in-gitlab)
  - [Pipeline steps](#pipeline-steps)
    - [Telegram notifications for jobs in pipeline](#telegram-notifications-for-jobs-in-pipeline)
  - [Some advices for Terraform CI/CD](#some-advices-for-terraform-cicd)

## Configuration description

### `yc-terraform-state-lock.tf`

This file creates S3 bucket and YDB instance to save state for our future project and perform state lock on changes.

As a result, it prints ready backend configuration to use in our CI/CD project. It also writes aws access keys into `.env` file.

### `main.tf`

This file creates SA for Terraform and writes access key into `.key.json` file. It also creates GitLab Runner machine.

## Set up backend in S3 with state lock

1. Run `terraform init`
2. Export environment from `yc` CLI:

    ```shell
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export AWS_ACCESS_KEY_ID="mock_access_key"
    export AWS_SECRET_ACCESS_KEY="mock_secret_key"
    ```

3. Run `terraform plan` & `terraform apply`
4. Save block `terraform {}` from outputs into `backend.tf` for your CI/CD project.

## Set up CI/CD in GitLab

1. Define envs:
   1. `AWS_ACCESS_KEY_ID` - static access key for backend from `.env` file.
   2. `AWS_SECRET_ACCESS_KEY` - static secret key for backend from `.env` file.
   3. `YC_CLOUD_ID` - cloud ID (can be set in `.tf` files).
   4. `YC_FOLDER_ID` - folder ID (can be set in `.tf` files).
   5. `YC_KEY` - access key json for terraform SA from `.key.json` (whole file).
2. Add new runner from CI/CD settings.
3. Log in into runner machine, that was created from base project. Register new runner with `docker` executor.
4. If you are from countries, where dockerhub sometimes gets inaccessible, you can set up mirrors for docker (don't forget to reload docker):

    ```shell
    cat <<EOF > /etc/docker/daemon.json
    {
    "registry-mirrors": [
        "https://mirror.gcr.io",
        "https://daocloud.io",
        "https://dockerhub.timeweb.cloud"
    ]
    }
    EOF
    ```

## Pipeline steps

This is simple example of a pipeline. It is defined in `.gitlab-ci.yml` file in `gitlab-project/` directory.

1. Validate terraform configuration with `terraform validate`
2. Perform SAST check with `checkov`
3. Use `tflint` to lint your files
4. Run `terraform plan`
5. Manual step for `terraform apply`
6. Manual step for `terraform destroy`

### Telegram notifications for jobs in pipeline

Simple example on how to send notifications in telegram about pipeline steps:

```yaml
after_script:
  - which curl &> /dev/null || apk add curl || (apt update; apt -y install curl)
  - >
    curl -X POST
    -F parse_mode="markdown"
    -F disable_web_page_preview="True"
    -F chat_id="${CHAT_ID}"
    -F message_thread_id="2"
    -F text="Pipeline: [${CI_PIPELINE_NAME}/${CI_PIPELINE_ID}](${CI_PIPELINE_URL}), Job: [${CI_JOB_NAME}](${CI_JOB_URL}) => *${CI_JOB_STATUS}*"
    "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
```

You have to define env vars `CHAT_ID` and `TG_TOKEN` to make it work. Also you can throw away `message_thread_id` if you are not using supergroup.

## Some advices for Terraform CI/CD

1. Document the code. Comments have to explain complex desicions or intentions.
2. Use `README.md` with description of your project.
3. Use [`terraform-docs`](https://github.com/terraform-docs/terraform-docs/) for module documentation.
4. Structure your project or module:

    ```plaintext
    /terraform
    ├── main.tf
    ├── variables.tf
    ├── versions.tf
    ├── outputs.tf
    ├── README.md
    └── ...
    ```

5. Break code into modules:

    ```plaintext
    /modules
    ├── web_server
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── README.md
    │   └── ...
    ├── database
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── README.md
    │   └── ...
    └── ...
    ```

6. Use different environments:

    ```plaintext
    /
    ├── environments/
    │   ├── dev/
    │   │   ├── variables.tf
    │   │   ├── main.tf
    │   │   └── ...
    │   ├── staging/
    │   │   ├── variables.tf
    │   │   ├── main.tf
    │   │   └── ...
    │   └── prod/
    │       ├── variables.tf
    │       ├── main.tf
    │       └── ...
    └── modules/
        ├── compute/
        ├── vpc/
        │   ├── main.tf
        │   └── variables.tf
        └── application
    ```

7. Import modules from local or remote sources. If you are working with known cloud providers, it is good to use official modules to save your time, write less code and make code more readable.
8. Use remote backend for terraform state file. It's better to also use state lock.
9. When working in Git, for adding new features use branching. After tests and applies merge into `main`. If possible, use pull requests & code review.
10. Automate your CI/CD pipeline with tools such as Gitlab CI or GitHub Actions.
