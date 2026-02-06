import { Module } from '@nestjs/common';
import { RoomsController } from './rooms.controller';
import { RoomsService } from './rooms.service';

/**
 * Module for handling room operations
 * POC for testing SQS → EventBridge → Lambda flow
 */
@Module({
  controllers: [RoomsController],
  providers: [RoomsService],
})
export class RoomsModule {}

