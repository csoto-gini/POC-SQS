# Rooms POC - Event-Driven Architecture

Complete proof of concept for serverless architecture with AWS.

**Architecture**: API → SQS → EventBridge → Lambda

## Project Structure

```
rooms-poc/
├── backend/              # NestJS Backend
│   ├── src/
│   ├── package.json
│   └── .env
├── infra/                # AWS Infrastructure (Terraform)
│   ├── lambda/
│   ├── *.tf
│   ├── deploy.sh
│   └── destroy.sh
├── README.md             # This file
└── DEPLOY.md             # Deployment guide
```

## Quick Start

### 1. Install Backend Dependencies

```bash
cd backend
npm install
```

### 2. Configure Credentials

Create the `backend/.env` file:

```bash
PORT=3001
NODE_ENV=development

# Your AWS credentials
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# We'll fill this after deployment
ROOMS_QUEUE_URL=
```

### 3. Deploy Infrastructure

```bash
cd infra

# Export credentials for Terraform
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key

# Deploy
./deploy.sh
```

### 4. Copy Queue URL

```bash
# Get the Queue URL
cd infra
terraform output sqs_queue_url

# Copy the result to backend/.env
```

### 5. Start Backend

```bash
cd backend
npm run start:dev
```

Server will be running on: http://localhost:3001

Swagger documentation: http://localhost:3001/api

### 6. Test

```bash
curl -X POST http://localhost:3001/rooms/message \
  -H "Content-Type: application/json" \
  -d '{
    "email1": "test1@example.com",
    "email2": "test2@example.com",
    "roomId": "test-room-123"
  }'
```

### 7. Verify Logs

```bash
aws logs tail /aws/lambda/gini-dev-rooms-processor --follow
```

## Architecture Flow

```
Client Request
    ↓
POST /rooms/message (NestJS Backend)
    ↓
Amazon SQS (Message Queue)
    ↓
EventBridge Pipe (Automatic connection)
    ↓
EventBridge Event Bus (Event routing)
    ↓
AWS Lambda (Processing)
    ↓
CloudWatch Logs (Storage)
```

## AWS Resources Created

- **SQS Queue**: gini-dev-rooms-queue
- **SQS DLQ**: gini-dev-rooms-dlq (Dead Letter Queue)
- **Event Bus**: gini-dev-rooms-event-bus
- **EventBridge Pipe**: gini-dev-rooms-pipe
- **Lambda Function**: gini-dev-rooms-processor
- **IAM Roles**: Required permissions for all services
- **CloudWatch Logs**: /aws/lambda/gini-dev-rooms-processor

## Technology Stack

**Backend**
- NestJS
- TypeScript
- AWS SDK for JavaScript (v3)
- Class Validator

**Infrastructure**
- Terraform
- AWS SQS
- AWS EventBridge
- AWS Lambda
- AWS CloudWatch

## Clean Up

To destroy all AWS resources:

```bash
cd infra
./destroy.sh
```

## Cost

All resources are within AWS Free Tier: **$0.00**

## Documentation

- **README.md** - This file (Quick start)
- **DEPLOY.md** - Detailed deployment guide
- **backend/README.md** - Backend documentation
- **infra/README.md** - Infrastructure documentation

## Troubleshooting

**Error: "ROOMS_QUEUE_URL is not defined"**

Check that `backend/.env` has the variable correctly set.

**Lambda doesn't execute**

- Check CloudWatch Logs at `/aws/lambda/gini-dev-rooms-processor`
- Verify that EventBridge Pipe is in RUNNING state
- Check IAM permissions

**Port 3001 in use**

Change `PORT` in `backend/.env` to another port.

**Invalid AWS credentials**

- Verify credentials are correct
- If using temporary credentials, ensure they haven't expired
- Check that `AWS_SESSION_TOKEN` is set if using temporary credentials

## Support

Having issues? Check:

1. CloudWatch logs for detailed error messages
2. That all AWS credentials are correct and not expired
3. That Terraform deployed without errors
4. SQS queue metrics in AWS Console

## License

ISC

## Author

GINI - Global Interpreting Network Inc
