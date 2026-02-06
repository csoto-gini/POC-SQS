# 🚀 Rooms POC Backend

Backend API para el POC de arquitectura event-driven con NestJS.

## 📋 Descripción

Este es un backend simple en NestJS que recibe mensajes de room y los envía a una cola SQS.

**Arquitectura**: `API → SQS → EventBridge → Lambda`

## 🔧 Instalación

```bash
# Instalar dependencias
npm install

# Copiar variables de entorno
cp .env.example .env

# Editar .env con tus credenciales
```

## ⚙️ Configuración

Edita el archivo `.env` con tus valores:

```bash
PORT=3001
NODE_ENV=development

# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key

# Rooms POC - SQS Configuration
ROOMS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/XXXXXX/gini-dev-rooms-queue
```

**Nota**: El `ROOMS_QUEUE_URL` lo obtienes del output de Terraform después de desplegar la infraestructura.

## 🚀 Ejecución

```bash
# Modo desarrollo (recomendado para POC)
npm run start:dev

# Modo producción
npm run build
npm run start:prod
```

El servidor estará en: `http://localhost:3001`

## 📚 Documentación API

Swagger está disponible en: `http://localhost:3001/api`

## 🧪 Probar el Endpoint

### Con cURL:

```bash
curl -X POST http://localhost:3001/rooms/message \
  -H "Content-Type: application/json" \
  -d '{
    "email1": "usuario1@ejemplo.com",
    "email2": "usuario2@ejemplo.com",
    "roomId": "sala-123"
  }'
```

### Respuesta esperada:

```json
{
  "success": true,
  "messageId": "12345-abcde-67890",
  "data": {
    "email1": "usuario1@ejemplo.com",
    "email2": "usuario2@ejemplo.com",
    "roomId": "sala-123",
    "timestamp": "2026-02-04T12:00:00.000Z"
  }
}
```

## 📁 Estructura del Proyecto

```
src/
├── main.ts                    # Entry point
├── app.module.ts              # Root module
└── rooms/
    ├── dto/
    │   └── create-room-message.dto.ts
    ├── rooms.controller.ts
    ├── rooms.service.ts
    └── rooms.module.ts
```

## 🔗 Flujo Completo

1. **Cliente** envía POST a `/rooms/message`
2. **Controller** valida los datos (DTO)
3. **Service** envía mensaje a SQS
4. **SQS** almacena el mensaje
5. **EventBridge Pipe** lee de SQS
6. **EventBridge** rutea el evento
7. **Lambda** procesa y registra en logs

## 📊 Verificar Logs

Ver logs de Lambda:

```bash
aws logs tail /aws/lambda/gini-dev-rooms-processor --follow
```

## 🐛 Troubleshooting

### Error: "ROOMS_QUEUE_URL is not defined"

**Solución**: Asegúrate de tener el `.env` configurado con el Queue URL.

### Error: "Access Denied" al enviar a SQS

**Solución**: Verifica que tus credenciales AWS sean correctas y tengan permisos de SQS.

### Puerto 3001 ya en uso

**Solución**: Cambia el `PORT` en el `.env` o detén el proceso que usa el puerto.

## 📖 Documentación Adicional

- Ver `../DEPLOYMENT_GUIDE.md` para guía completa de despliegue
- Ver `../POC_SUMMARY.md` para resumen del proyecto
- Ver `../infra/stacks/rooms-poc/README.md` para documentación de infraestructura

