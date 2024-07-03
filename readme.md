# File Backup

This Docker image will backup a chosen directory from a Docker volume and copy the backup files to Google Drive using rclone. It must have access to the Docker volume that is to be backed up. The entire contents of the chosen directory will be tarred and gziped once a day at 00:05 UTC. The backups will be saved in another Docker volume and will be named `backup-<time>.tar.gz`. `<time>` is the full ISO 8601 date and time with colons replaced by hyphens for file name compatibility, e.g. `backup-2000-12-31T00-05-01+00-00.tar.gz`.

Steps for use:

1. Configure the `.env` files
2. Build the Docker image
3. Provide a Google service account private key
4. Run on a Docker server

## 1. Configuring

Configuration settings are specified in two files, both named `.env`. The provided `.env` files can be used as a templates. The top-level `.env` file is used for running the image. The `.env` file in the `compose-build` directory is used for building the image.

### Required settings

- DATA_VOLUME  
The name of an existing Docker volume containing the data to be backed up. You can view the volumes that a container is attached to by running `docker container inspect <containerName>` and looking in the `"Mounts"` section.
- DATA_DIR  
The absolute path to the directory on the above volume that will be backed up.
- BACKUP_VOLUME  
The name of a Docker volume that will be used to persist the backup files.
- DRIVE_FOLDER_ID  
The Google Drive folder ID of a folder that is shared with the chosen service account with edit permission. See <https://rclone.org/drive/#root-folder-id> for instructions on how to find a folder's ID. This is required because otherwise rclone will save the files in the Google Drive of the service account, instead of a user account, and these files are not easily accessible. See the section under 'Other Notes' for more details about the service account.

### Optional settings

- DOCKER_REGISTRY  
The address of your Docker registry, from the perspective of the Docker server that the program will run on, e.g. `localhost:5000/`. If set, a trailing `/` **must** be included. If omitted, the local Docker Desktop registry is used, if present, otherwise, Docker Hub.
- DOCKER_TAG  
The tag to use when retrieving this program's image from the registry. If a tag is not provided, 'latest' will be used.

## 2. Building

From the `compose-build` directory, run `docker compose build`. If building on a different computer than the program will be run, make sure to also run `docker compose push`.

## 3. Service account private key

The private key file for a Google service account needs to be obtained and named `drive_key.json`. See the section under ‘Other Notes’ for more details about the service account.

## 4. Running

Make a directory on your Docker server for this program. A good location would be the user's home directory, and a good name would be something that reflects what program or directory this program will back up, e.g. `~/myprogram-backup/`. Copy the `docker-compose.yml` and `.env` files and the `secrets` directory to this directory. Copy the `drive_key.json` file from the previous step to the `secrets` directory. Finally, run `docker compose up -d` from within the directory.

## Other Notes

### Viewing logs

To view the log output of this program, run `docker logs <containerName>` or `docker logs -f <containerName>` to follow the log output. This will show the output of the backup commands which can be used to help diagnose any problems. To view the names of running containers, run `docker ps`. The container for this program should be named `<folderOfTheDocker-Compose.ymlFile>_file-backup_1`.

### Interactive login and running scripts manually

To connect to the container to run the backup script manually, run `docker exec -it <containerName> ash`. The backup script is located in the home directory and named `file_backup.sh`. Note that the output of the script is redirected to the Docker logs, so it's advisable to follow the logs in another terminal when running it.

### Service account and Google Drive permissions

In order to enable unattended operation, rclone is configured to use a Google service account instead of a normal Google user account. Service accounts allow for perpetual unattended use while user accounts may require periodic reauthentication. See <https://rclone.org/drive/#service-account-support> for instructions on how to create and use a service account. In order for this service account to copy files to a user account, a folder in the user's Google Drive must be shared with the service account with edit permission.
