import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

/**
 * DTO for creating a room message
 * This will be sent to SQS for processing
 */
export class CreateRoomMessageDto {
  @ApiProperty({
    description: 'Email address of the first participant',
    example: 'user1@example.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email1: string;

  @ApiProperty({
    description: 'Email address of the second participant',
    example: 'user2@example.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email2: string;

  @ApiProperty({
    description: 'Unique identifier for the room',
    example: 'room-123-abc',
  })
  @IsString()
  @IsNotEmpty()
  roomId: string;
}

