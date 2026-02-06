import { Body, Controller, Post, Logger } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { RoomsService } from './rooms.service';
import { CreateRoomMessageDto } from './dto/create-room-message.dto';

/**
 * Controller to handle room-related endpoints
 * POC for SQS → EventBridge → Lambda flow
 */
@ApiTags('rooms')
@Controller('rooms')
export class RoomsController {
  private readonly logger = new Logger(RoomsController.name);

  constructor(private readonly roomsService: RoomsService) {}

  /**
   * Endpoint to receive room data and send it to SQS
   * @param createRoomMessageDto - Contains email1, email2, and roomId
   */
  @Post('message')
  @ApiOperation({ summary: 'Send room message to processing queue' })
  @ApiResponse({
    status: 201,
    description: 'Message sent successfully to SQS',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input data',
  })
  async sendMessage(@Body() createRoomMessageDto: CreateRoomMessageDto) {
    this.logger.log(
      `Received room message request for roomId: ${createRoomMessageDto.roomId}`,
    );

    // Send to SQS
    const result =
      await this.roomsService.sendRoomMessage(createRoomMessageDto);

    return result;
  }
}

