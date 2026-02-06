# 🚀 Rooms POC - Arquitectura Event-Driven

Prueba de concepto completa para arquitectura serverless con AWS.

**Arquitectura**: `API → SQS → EventBridge → Lambda`

## 📁 Estructura del Proyecto

```
rooms-poc/
├── backend/              # Backend NestJS
│   ├── src/
│   ├── package.json
│   └── .env
├── infra/                # Infraestructura AWS (Terraform)
│   ├── lambda/
│   ├── *.tf
│   ├── deploy.sh
│   └── destroy.sh
├── README.md             # Este archivo
└── DEPLOY.md             # Guía de despliegue
```

## ⚡ Inicio Rápido

### 1️⃣ Instalar Dependencias del Backend

```bash
cd backend
npm install
```

### 2️⃣ Configurar Credenciales

Crea el archivo `backend/.env`:

```bash
PORT=3001
NODE_ENV=development

# Tus credenciales AWS
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key

# Este lo llenaremos después
ROOMS_QUEUE_URL=
```

### 3️⃣ Desplegar Infraestructura

```bash
cd infra

# Exportar credenciales para Terraform
export AWS_ACCESS_KEY_ID=tu_access_key
export AWS_SECRET_ACCESS_KEY=tu_secret_key

# Deploy
./deploy.sh
```

### 4️⃣ Copiar Queue URL

```bash
# Obtener el Queue URL
cd infra
terraform output sqs_queue_url

# Copiar el resultado a backend/.env
# ROOMS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/...
```

### 5️⃣ Iniciar Backend

```bash
cd backend
npm run start:dev
```

Verás:
```
🚀 Server is running on: http://localhost:3001
📚 Swagger documentation: http://localhost:3001/api
```

### 6️⃣ Probar

```bash
curl -X POST http://localhost:3001/rooms/message \
  -H "Content-Type: application/json" \
  -d '{
    "email1": "test1@example.com",
    "email2": "test2@example.com",
    "roomId": "sala-test-123"
  }'
```

### 7️⃣ Verificar Logs

```bash
aws logs tail /aws/lambda/gini-dev-rooms-processor --follow
```

## 📊 Arquitectura

```
Cliente
  ↓
POST /rooms/message (NestJS Backend)
  ↓
Amazon SQS (Cola de mensajes)
  ↓
EventBridge Pipe (Conexión automática)
  ↓
EventBridge Event Bus (Ruteo de eventos)
  ↓
AWS Lambda (Procesamiento)
  ↓
CloudWatch Logs (Registros)
```

## 🔑 Recursos AWS Creados

- **SQS Queue**: gini-dev-rooms-queue
- **SQS DLQ**: gini-dev-rooms-dlq
- **Event Bus**: gini-dev-rooms-event-bus
- **EventBridge Pipe**: gini-dev-rooms-pipe
- **Lambda**: gini-dev-rooms-processor
- **IAM Roles**: Permisos necesarios
- **CloudWatch Logs**: /aws/lambda/gini-dev-rooms-processor

## 🧹 Limpiar Recursos

```bash
cd infra
./destroy.sh
```

## 💰 Costos

Todo dentro del Free Tier de AWS = **$0.00** ✅

## 📚 Documentación

- **README.md** (este archivo) - Inicio rápido
- **DEPLOY.md** - Guía detallada de despliegue
- **backend/README.md** - Documentación del backend
- **infra/README.md** - Documentación de infraestructura

## 🐛 Troubleshooting

**Error: "ROOMS_QUEUE_URL is not defined"**
- Verifica que `backend/.env` tenga la variable

**Lambda no se ejecuta**
- Revisa CloudWatch Logs
- Verifica que el EventBridge Pipe esté activo

**Puerto 3001 en uso**
- Cambia `PORT` en `backend/.env`

## 📞 Soporte

¿Problemas? Revisa:
1. Los logs de CloudWatch
2. Que todas las credenciales estén correctas
3. Que Terraform haya desplegado sin errores

---

**¡Listo para empezar!** 🎉

Sigue los pasos del 1️⃣ al 7️⃣ y en 10 minutos tendrás todo funcionando.

