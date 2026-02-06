import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

/**
 * Bootstrap the NestJS application
 * This is the entry point of the application
 */
async function bootstrap() {
  // Create NestJS application
  const app = await NestFactory.create(AppModule);

  // Enable CORS for development
  app.enableCors();

  // Enable global validation pipe
  // This will automatically validate all incoming requests
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Setup Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('Rooms POC API')
    .setDescription('POC for Event-Driven Architecture: API → SQS → EventBridge → Lambda')
    .setVersion('1.0')
    .addTag('rooms')
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  // Get port from environment or use default
  const port = process.env.PORT || 3001;
  
  await app.listen(port);
  
  console.log('');
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║         Rooms POC Backend - Running                   ║');
  console.log('╚════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`🚀 Server is running on: http://localhost:${port}`);
  console.log(`📚 Swagger documentation: http://localhost:${port}/api`);
  console.log('');
  console.log('Available endpoints:');
  console.log(`  POST http://localhost:${port}/rooms/message`);
  console.log('');
}

bootstrap();

