# MinIO Action

GitHub Action for running MinIO server in your workflow. MinIO is a high-performance object storage solution compatible with Amazon S3 APIs.

You can use this action to test your S3 integration in your GitHub Actions workflows.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `access_key` | Access key ID for MinIO server | Yes | `minio` |
| `secret_key` | Secret access key for MinIO server | Yes | `miniotest` |
| `port` | Port number for MinIO server | No | `9000` |
| `bucket_name` | Create a bucket with the given name | No | |

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

You can use boto3 with MinIO server by setting the endpoint URL.

Here's how to set up a pytest fixture for MinIO testing:

```python
import pytest
import boto3
from botocore.client import Config

@pytest.fixture
def s3client():
    """Fixture for S3 client connected to MinIO"""
    return boto3.client(
        's3',
        endpoint_url='http://127.0.0.1:9000',
        aws_access_key_id='minio',
        aws_secret_access_key='minio123',
        config=Config(signature_version='s3v4')
    )

@pytest.fixture
def test_bucket(s3client):
    """Fixture that creates and tears down a test bucket"""
    bucket_name = 'test-bucket'
    s3client.create_bucket(Bucket=bucket_name)
    yield bucket_name
    # Cleanup: delete all objects and the bucket after test
    try:
        s3client.delete_bucket(Bucket=bucket_name)
    except Exception as e:
        print(f"Cleanup error: {e}")

def test_file_upload(s3client, test_bucket):
    """Test file upload functionality"""
    # Upload test file
    s3client.put_object(
        Bucket=test_bucket,
        Key='test.txt',
        Body='test content'
    )
    
    # Verify upload
    response = s3client.get_object(Bucket=test_bucket, Key='test.txt')
    assert response['Body'].read().decode() == 'test content'
```

## Using with Node.js (TypeScript)

You can use the `aws-sdk` package to interact with MinIO server in a Node.js (TypeScript) application.

Example of setting up S3 client for Jest testing:

```typescript
import { S3 } from 'aws-sdk';

describe('S3 Operations', () => {
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

        // Create test bucket
        await s3Client.createBucket({ Bucket: TEST_BUCKET }).promise();
    });

    afterAll(async () => {
        // Clean up: delete all objects and bucket
        try {
            await s3Client.deleteBucket({ Bucket: TEST_BUCKET }).promise();
        } catch (error) {
            console.error('Cleanup error:', error);
        }
    });

    test('should upload and retrieve file', async () => {
        // Upload test file
        await s3Client
            .putObject({
                Bucket: TEST_BUCKET,
                Key: 'test.txt',
                Body: 'test content'
            })
            .promise();

        // Retrieve and verify
        const response = await s3Client
            .getObject({
                Bucket: TEST_BUCKET,
                Key: 'test.txt'
            })
            .promise();

        expect(response.Body?.toString()).toBe('test content');
    });
});
```

## License

MIT License
