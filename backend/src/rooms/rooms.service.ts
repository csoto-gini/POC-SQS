import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import { CreateRoomMessageDto } from './dto/create-room-message.dto';

/**
 * Service to handle room operations
 * Sends messages to SQS for async processing
 */
@Injectable()
export class RoomsService {
  private readonly logger = new Logger(RoomsService.name);
  private readonly sqsClient: SQSClient;
  private readonly queueUrl: string;

  constructor(private readonly configService: ConfigService) {
    // Get AWS credentials from environment
    const accessKeyId = this.configService.get('AWS_ACCESS_KEY_ID');
    const secretAccessKey = this.configService.get('AWS_SECRET_ACCESS_KEY');
    const sessionToken = this.configService.get('AWS_SESSION_TOKEN');

    // Log credentials para debug (solo las primeras letras)
    this.logger.log(`AWS Credentials loaded:`);
    this.logger.log(`  Access Key: ${accessKeyId?.substring(0, 10)}...`);
    this.logger.log(`  Secret Key: ${secretAccessKey ? '***' : 'NOT FOUND'}`);
    this.logger.log(`  Session Token: ${sessionToken ? 'EXISTS' : 'NOT FOUND'}`);

    // Initialize SQS client with AWS credentials from env
    const credentials: any = {
      accessKeyId,
      secretAccessKey,
    };

    // Add session token if it exists (for temporary credentials)
    if (sessionToken) {
      credentials.sessionToken = sessionToken;
    }

    this.sqsClient = new SQSClient({
      region: this.configService.get('AWS_REGION', 'us-east-1'),
      credentials,
    });

    // Get SQS queue URL from environment variables
    this.queueUrl = this.configService.get('ROOMS_QUEUE_URL');
    this.logger.log(`Queue URL: ${this.queueUrl}`);
  }

  /**
   * Send room message to SQS queue
   * @param createRoomMessageDto - The message data to send
   * @returns The SQS message ID
   */
  async sendRoomMessage(createRoomMessageDto: CreateRoomMessageDto) {
    try {
      // Create the message payload
      const messageBody = {
        email1: createRoomMessageDto.email1,
        email2: createRoomMessageDto.email2,
        roomId: createRoomMessageDto.roomId,
        timestamp: new Date().toISOString(),
      };

      // Send message to SQS
      const command = new SendMessageCommand({
        QueueUrl: this.queueUrl,
        MessageBody: JSON.stringify(messageBody),
        MessageAttributes: {
          roomId: {
            DataType: 'String',
            StringValue: createRoomMessageDto.roomId,
          },
        },
      });

      const result = await this.sqsClient.send(command);

      this.logger.log(
        `Message sent to SQS successfully. MessageId: ${result.MessageId}`,
      );

      return {
        success: true,
        messageId: result.MessageId,
        data: messageBody,
      };
    } catch (error) {
      this.logger.error('Error sending message to SQS', error);
      throw error;
    }
  }
}

