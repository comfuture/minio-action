# MinIO Action

GitHub Action for running MinIO server in your workflow. MinIO is a high-performance object storage solution compatible with Amazon S3 APIs.

You can use this action to test your S3 integration in your GitHub Actions workflows.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `access_key` | Access key ID for MinIO server | Yes | `minio` |
| `secret_key` | Secret access key for MinIO server | Yes | `miniotest` |
| `port` | Port number for MinIO server | No | `9000` |
| `bucket_name` | Create a bucket with the given name | No | `""` |

If you set `bucket_name`, the action will create a bucket with the given name.

## Usage

Basic usage:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Start MinIO Server
    uses: comfuture/minio-action@v1
    with:
      access_key: minio
      secret_key: minio123
```

With custom port and bucket creation:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Start MinIO Server
    uses: comfuture/minio-action@v1
    with:
      access_key: minio
      secret_key: minio123
      port: 9090
      bucket_name: my-test-bucket
```

## Using with AWS CLI

The action sets up MinIO server to be compatible with AWS CLI. You can use AWS CLI commands with the `--endpoint-url` parameter:

```bash
aws --endpoint-url http://127.0.0.1:9000 s3 ls
```

## Using with boto3

You can use boto3 with MinIO server by setting the endpoint URL:

```python
import boto3
from botocore.client import Config

# Initialize a session using MinIO server
s3 = boto3.resource(
  's3',
  endpoint_url='http://127.0.0.1:9000',
  aws_access_key_id='minio',
  aws_secret_access_key='minio123',
  config=Config(signature_version='s3v4')
)

# Create a new bucket
s3.create_bucket(Bucket='my-test-bucket')

# List all buckets
for bucket in s3.buckets.all():
  print(bucket.name)

# Upload a new file
s3.Bucket('my-test-bucket').upload_file('test.txt', 'test.txt')
```

## Using with Node.js (TypeScript)

You can use the `aws-sdk` package to interact with MinIO server in a Node.js (TypeScript) application:

```typescript
import AWS from 'aws-sdk';

// Configure the AWS SDK with MinIO server details
const s3 = new AWS.S3({
  endpoint: 'http://127.0.0.1:9000',
  accessKeyId: 'minio',
  secretAccessKey: 'minio123',
  s3ForcePathStyle: true, // needed with minio
  signatureVersion: 'v4'
});

// Create a new bucket
s3.createBucket({ Bucket: 'my-test-bucket' }, (err, data) => {
  if (err) console.log(err, err.stack);
  else console.log('Bucket Created Successfully', data.Location);
});

// List all buckets
s3.listBuckets((err, data) => {
  if (err) console.log(err, err.stack);
  else console.log('Bucket List', data.Buckets);
});

// Upload a new file
const uploadParams = { Bucket: 'my-test-bucket', Key: 'test.txt', Body: 'Hello from MinIO!' };
s3.upload(uploadParams, (err, data) => {
  if (err) console.log(err, err.stack);
  else console.log('File Uploaded Successfully', data.Location);
});
```

## License

MIT License
