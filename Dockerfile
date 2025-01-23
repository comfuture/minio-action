FROM minio/minio:latest

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE ${PORT:-9000}

ENTRYPOINT ["/entrypoint.sh"]