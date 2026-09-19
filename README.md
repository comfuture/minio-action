# Silo Action

GitHub Action for running a [Silo](https://silo.pgsty.com/) server in a workflow. Silo is a community-maintained fork of the open-source MinIO server and provides an S3-compatible API.

Use this action to test an application's S3 integration without connecting to an external object storage service.

## Breaking changes in v2

Version 2 moves the action from MinIO to Silo because the previously used MinIO image is no longer available from Docker Hub.

- The repository and action reference change from `comfuture/minio-action` to `comfuture/silo-action`.
- The server image changes from `dhi/minio` to `docker.io/pgsty/silo:latest`.
- The running container is named `silo` instead of `minio`. Update any workflow commands that use the container name directly, such as `docker logs` or `docker exec`.
- The temporary data directory changes from `/tmp/data` to `/tmp/silo-data`.
- The action inputs and their defaults are unchanged.
- Silo intentionally retains the `MINIO_*` configuration contract for compatibility. This action uses `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` when starting the Silo container; do not rename those variables to `SILO_*`.

Update existing workflows as follows:

```diff
- uses: comfuture/minio-action@v1
+ uses: comfuture/silo-action@v2
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `access_key` | Access key ID for the Silo server | Yes | `minio` |
| `secret_key` | Secret access key for the Silo server | Yes | `miniotest` |
| `port` | Host port for the Silo S3 API | No | `9000` |
| `bucket_name` | Bucket to create after Silo is ready | No | |

When `bucket_name` is set, the action waits for Silo to become ready and creates the bucket with the AWS CLI. The action also exports `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_EC2_METADATA_DISABLED` for later workflow steps.

## Usage

Basic usage:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Start Silo server
    uses: comfuture/silo-action@v2
    with:
      access_key: minio
      secret_key: minio123
```

With a custom port and bucket:

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Start Silo server
    uses: comfuture/silo-action@v2
    with:
      access_key: minio
      secret_key: minio123
      port: 9090
      bucket_name: my-test-bucket
```

## Using the AWS CLI

Pass the local Silo endpoint to the AWS CLI:

```bash
aws --endpoint-url http://127.0.0.1:9000 s3 ls
```

## Using boto3

The following pytest fixture creates a boto3 client connected to Silo:

```python
import boto3
import pytest
from botocore.client import Config


@pytest.fixture
def s3client():
    """Create an S3 client connected to Silo."""
    return boto3.client(
        "s3",
        endpoint_url="http://127.0.0.1:9000",
        aws_access_key_id="minio",
        aws_secret_access_key="minio123",
        config=Config(signature_version="s3v4"),
    )


@pytest.fixture
def test_bucket(s3client):
    """Create and remove a bucket used by a test."""
    bucket_name = "test-bucket"
    s3client.create_bucket(Bucket=bucket_name)
    yield bucket_name
    try:
        s3client.delete_bucket(Bucket=bucket_name)
    except Exception as error:
        print(f"Cleanup error: {error}")


def test_file_upload(s3client, test_bucket):
    s3client.put_object(
        Bucket=test_bucket,
        Key="test.txt",
        Body="test content",
    )

    response = s3client.get_object(Bucket=test_bucket, Key="test.txt")
    assert response["Body"].read().decode() == "test content"
```

## Using Node.js with TypeScript

The following Jest example uses the AWS SDK for JavaScript v2 with Silo:

```typescript
import { S3 } from 'aws-sdk';

describe('S3 operations', () => {
    let s3Client: S3;
    const TEST_BUCKET = 'test-bucket';

    beforeAll(async () => {
        s3Client = new S3({
            endpoint: 'http://127.0.0.1:9000',
            accessKeyId: 'minio',
            secretAccessKey: 'minio123',
            s3ForcePathStyle: true,
            signatureVersion: 'v4'
        });

        await s3Client.createBucket({ Bucket: TEST_BUCKET }).promise();
    });

    afterAll(async () => {
        try {
            await s3Client.deleteBucket({ Bucket: TEST_BUCKET }).promise();
        } catch (error) {
            console.error('Cleanup error:', error);
        }
    });

    test('uploads and retrieves a file', async () => {
        await s3Client
            .putObject({
                Bucket: TEST_BUCKET,
                Key: 'test.txt',
                Body: 'test content'
            })
            .promise();

        const response = await s3Client
            .getObject({ Bucket: TEST_BUCKET, Key: 'test.txt' })
            .promise();

        expect(response.Body?.toString()).toBe('test content');
    });
});
```

## Silo compatibility

Silo keeps the S3 API, storage format, reserved `/minio/*` routes, and `MINIO_*` environment variables compatible with the open-source MinIO server. See the [Silo compatibility notes](https://silo.pgsty.com/compatibility/server/) before adopting a new Silo release.

Silo is an independent community project and is not affiliated with, endorsed by, or sponsored by MinIO, Inc.

## License

MIT License
