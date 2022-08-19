FROM alpine:3.16

# Install packages.
RUN \
  apk update && \
  apk upgrade && \
  apk add \
  rclone && \
  rm -rf /var/cache/apk/*

# Copy backup script, crontab, and rclone configuration.
COPY --chmod=744 entrypoint.sh /root/entrypoint.sh
COPY --chmod=744 file_backup.sh /root/file_backup.sh
COPY --chmod=644 root /etc/crontabs/root
COPY rclone.conf /root/rclone.conf
COPY drive_key.json /root/drive_key.json
RUN mkdir -p /root/.config/rclone

# Setup the rclone configuration then run cron in the foreground.
ENTRYPOINT ["/root/entrypoint.sh"]
