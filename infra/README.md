# Rooms POC - Architecture Documentation

## 📋 Overview

This is a Proof of Concept (POC) for a serverless event-driven architecture that demonstrates the flow:

**API Endpoint → SQS → EventBridge → Lambda**

### Architecture Components

1. **NestJS API Endpoint**: Receives room messages (email1, email2, roomId)
2. **Amazon SQS**: Message queue for async processing
3. **EventBridge Pipe**: Connects SQS to EventBridge Event Bus
4. **EventBridge Event Bus**: Routes events to targets
5. **AWS Lambda**: Processes the room messages (logs data for POC)

## 🏗️ Architecture Flow

```
┌─────────────┐
│  NestJS API │
│  (Endpoint) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Amazon SQS │
│   (Queue)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ EventBridge │
│    Pipe     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ EventBridge │
│  Event Bus  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│AWS Lambda   │
│ (Processor) │
└─────────────┘
```

## 🚀 Deployment Steps

### Prerequisites

1. AWS CLI configured with credentials
2. Terraform installed (v1.0+)
3. Node.js 20+ for NestJS backend
4. Access to AWS account with permissions for: SQS, EventBridge, Lambda, IAM

### Step 1: Deploy Infrastructure with Terraform

```bash
# Navigate to the rooms-poc stack directory
cd infra/stacks/rooms-poc

# Initialize Terraform
terraform init -backend-config=backend.tfbackend

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply

# Note the outputs - you'll need the SQS queue URL
```

### Step 2: Configure Backend Environment Variables

Add the following variables to your `.env` file in the `data-collection-backend/` directory:

```bash
# Rooms POC - SQS Configuration
ROOMS_QUEUE_URL=<sqs_queue_url_from_terraform_output>

# AWS Configuration (if not already set)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=<your_access_key>
AWS_SECRET_ACCESS_KEY=<your_secret_key>
```

To get the SQS queue URL from Terraform:

```bash
cd infra/stacks/rooms-poc
terraform output sqs_queue_url
```

### Step 3: Install Backend Dependencies

```bash
# Navigate to backend directory
cd data-collection-backend

# Install dependencies (includes @aws-sdk/client-sqs)
npm install
```

### Step 4: Start the Backend Server

```bash
# Development mode
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

The API will be available at `http://localhost:3000`

## 🧪 Testing the POC

### 1. Send a Test Message via API

Using curl:

```bash
curl -X POST http://localhost:3000/rooms/message \
  -H "Content-Type: application/json" \
  -d '{
    "email1": "user1@example.com",
    "email2": "user2@example.com",
    "roomId": "room-123-abc"
  }'
```

Using Postman or similar:
- **Method**: POST
- **URL**: `http://localhost:3000/rooms/message`
- **Headers**: `Content-Type: application/json`
- **Body**:
```json
{
  "email1": "user1@example.com",
  "email2": "user2@example.com",
  "roomId": "room-123-abc"
}
```

### 2. Verify the Message Flow

#### Check SQS Queue

```bash
# List messages in the queue (AWS CLI)
aws sqs receive-message \
  --queue-url <your-queue-url> \
  --region us-east-1
```

#### Check Lambda Logs

```bash
# View Lambda logs (CloudWatch)
aws logs tail /aws/lambda/gini-dev-rooms-processor --follow
```

Or via AWS Console:
1. Go to CloudWatch → Log groups
2. Find `/aws/lambda/gini-dev-rooms-processor`
3. View the latest log stream

You should see output like:
```
=== Room Message Lambda Handler Started ===
Event received: {...}
=== Room Message Details ===
Email 1: user1@example.com
Email 2: user2@example.com
Room ID: room-123-abc
Timestamp: 2026-02-04T...
===========================
```

## 📊 Monitoring

### CloudWatch Dashboards

Monitor the following metrics:
- **SQS**: Number of messages sent/received
- **Lambda**: Invocations, duration, errors
- **EventBridge**: Events matched, invocations

### Dead Letter Queue

Failed messages will be sent to the DLQ. Check it with:

```bash
aws sqs receive-message \
  --queue-url <your-dlq-url> \
  --region us-east-1
```

## 🔧 Troubleshooting

### Message Not Appearing in Lambda

1. **Check SQS Queue**: Verify message is in the queue
   ```bash
   aws sqs get-queue-attributes \
     --queue-url <queue-url> \
     --attribute-names ApproximateNumberOfMessages
   ```

2. **Check EventBridge Pipe**: Ensure pipe is active
   ```bash
   aws pipes list-pipes
   ```

3. **Check IAM Permissions**: Verify roles have correct permissions

4. **Check Lambda Function**: Test directly
   ```bash
   aws lambda invoke \
     --function-name gini-dev-rooms-processor \
     --payload '{"detail": {"email1": "test@test.com", "email2": "test2@test.com", "roomId": "test-123"}}' \
     response.json
   ```

### Backend Connection Issues

1. **Check Environment Variables**: Ensure `.env` file has correct values
2. **Check AWS Credentials**: Verify credentials have SQS permissions
3. **Check Queue URL**: Ensure it matches Terraform output

## 🧹 Cleanup

To destroy all resources:

```bash
cd infra/stacks/rooms-poc
terraform destroy
```

## 📝 Next Steps

This POC demonstrates the basic flow. For production:

1. **Add Authentication**: Secure the API endpoint
2. **Add Validation**: Enhanced input validation
3. **Add Business Logic**: Replace Lambda log-only code with actual processing
4. **Add Monitoring**: Set up CloudWatch alarms
5. **Add Error Handling**: Comprehensive error management
6. **Add Testing**: Unit and integration tests

## 🔐 Required AWS Permissions

Ensure your AWS credentials have the following permissions:
- `sqs:*`
- `events:*`
- `lambda:*`
- `iam:*`
- `logs:*`
- `pipes:*`

## 📚 Resources

- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [EventBridge Pipes](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-pipes.html)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [NestJS Documentation](https://docs.nestjs.com/)

