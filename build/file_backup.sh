#!/bin/ash

time=$(date -Iseconds)
# Replace ':' with '-' for use in file name.
time=${time//:/-}
file_name=backup-${time}.tar.gz

{ # Redirect output to init so it shows up in the docker log.
	echo
	echo "$(date -Iseconds): Starting backup to ${file_name}"
	tar -czf /root/backup/${file_name} -C /mnt/data "${DATA_DIR:1}"
	
	# Confirm file exists.
	if [[ -f /root/backup/${file_name} ]]; then
		# Copy backup to backup service.
		echo
		echo "$(date -Iseconds): Copying backup to backup service"
		rclone -v copy /root/backup/${file_name} drive:/
	fi
} >/proc/1/fd/1 2>/proc/1/fd/2
