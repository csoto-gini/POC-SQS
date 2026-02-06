import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { RoomsModule } from './rooms/rooms.module';

/**
 * Root module of the application
 * This is a simple POC, so we only have the RoomsModule
 */
@Module({
  imports: [
    // Global configuration module
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: `${process.cwd()}/.env`,
    }),
    // Rooms module for the POC
    RoomsModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}

