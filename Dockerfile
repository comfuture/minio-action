FROM minio/mc:latest AS mc
FROM minio/minio:latest

COPY --from=mc /bin/mc /bin/mc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE ${PORT:-9000}

ENTRYPOINT ["/entrypoint.sh"]