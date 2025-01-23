FROM minio/minio:latest

RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
RUN chmod +x $HOME/minio-binaries/mc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE ${PORT:-9000}

ENTRYPOINT ["/entrypoint.sh"]