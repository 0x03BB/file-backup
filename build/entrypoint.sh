#!/bin/ash

# Add the root folder id to the rclone configuration.
cp /root/rclone.conf /root/.config/rclone/rclone.conf
echo "root_folder_id = ${ROOT_FOLDER_ID}" >> /root/.config/rclone/rclone.conf

# Run cron in the foreground.
echo "Entrypoint: Starting cron." > /proc/1/fd/1
exec crond -f -l 2
