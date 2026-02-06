# 📁 Estructura del Proyecto - Rooms POC

## Vista General del Proyecto GINI

```
GINI/
├── 📂 data-collection-backend/        # Backend principal (sin cambios)
│   └── ...archivos existentes
│
├── 📂 rooms-poc-backend/              # ✨ NUEVO - Backend del POC
│   ├── src/
│   │   ├── main.ts                    # Entry point
│   │   ├── app.module.ts              # Root module
│   │   └── rooms/
│   │       ├── dto/
│   │       │   └── create-room-message.dto.ts
│   │       ├── rooms.controller.ts
│   │       ├── rooms.service.ts
│   │       └── rooms.module.ts
│   ├── package.json
│   ├── tsconfig.json
│   ├── nest-cli.json
│   ├── .gitignore
│   ├── .prettierrc
│   ├── README.md
│   └── .env                           # ⚠️ Debes crear este archivo
│
├── 📂 infra/
│   └── stacks/
│       └── rooms-poc/                 # ✨ NUEVO - Stack completo del POC
│           ├── lambda/
│           │   ├── index.js           # Código Lambda
│           │   └── function.zip       # (Se genera automáticamente)
│           ├── provider.tf
│           ├── variables.tf
│           ├── main.tf
│           ├── sqs.tf                 # SQS Queue + DLQ
│           ├── eventbridge.tf         # Event Bus + Pipe + Rules
│           ├── lambda.tf              # Lambda Function
│           ├── iam.tf                 # IAM Roles & Policies
│           ├── outputs.tf
│           ├── terraform.tfvars
│           ├── backend.tfbackend
│           ├── deploy.sh              # Script de despliegue
│           ├── destroy.sh             # Script de limpieza
│           ├── README.md              # Documentación técnica
│           └── PROJECT_STRUCTURE.md   # Este archivo
│
├── 📄 DEPLOYMENT_GUIDE.md             # ✨ NUEVO - Guía paso a paso
└── 📄 POC_SUMMARY.md                  # ✨ NUEVO - Resumen completo
```

## 🔍 Detalle de Archivos Nuevos

### Backend NestJS

#### `src/rooms/dto/create-room-message.dto.ts`
```typescript
- Valida email1, email2, roomId
- Usa class-validator
- Documentado con ApiProperty para Swagger
```

#### `src/rooms/rooms.controller.ts`
```typescript
- Endpoint POST /rooms/message
- Recibe CreateRoomMessageDto
- Retorna success + messageId + data
```

#### `src/rooms/rooms.service.ts`
```typescript
- Inicializa cliente SQS
- Envía mensajes a la cola
- Agrega timestamp automáticamente
- Logging de operaciones
```

#### `src/rooms/rooms.module.ts`
```typescript
- Registra controller y service
- Módulo standalone de NestJS
```

### Infraestructura Terraform

#### `sqs.tf`
```hcl
- SQS Queue (cola principal)
  * Retention: 4 días
  * Visibility timeout: 30s
  * DLQ configurado (3 reintentos)
  
- SQS DLQ (Dead Letter Queue)
  * Retention: 14 días
  
- Queue Policy
  * Permite lectura a EventBridge Pipe
```

#### `eventbridge.tf`
```hcl
- Event Bus (custom)
  * Nombre: gini-dev-rooms-event-bus
  
- EventBridge Pipe
  * Source: SQS Queue
  * Target: Event Bus
  * Batch size: 1
  * Transform automático
  
- EventBridge Rule
  * Filtra por source="rooms.api"
  * Filtra por detail-type="RoomMessage"
  
- Event Target
  * Target: Lambda Function
  * Permisos de invocación
```

#### `lambda.tf`
```hcl
- Lambda Function
  * Runtime: Node.js 20
  * Handler: index.handler
  * Timeout: 30s
  * Memory: 128 MB
  
- CloudWatch Log Group
  * Retention: 7 días
  * Path: /aws/lambda/gini-dev-rooms-processor
```

#### `iam.tf`
```hcl
- Lambda IAM Role
  * AssumeRole para lambda.amazonaws.com
  * Policy: CloudWatch Logs
  
- EventBridge Pipe IAM Role
  * AssumeRole para pipes.amazonaws.com
  * Policy: Read SQS
  * Policy: Write EventBridge
```

#### `lambda/index.js`
```javascript
- Handler async
- Log del evento completo
- Extrae detail del evento
- Muestra email1, email2, roomId, timestamp
- Return 200 o 500
```

### Scripts de Ayuda

#### `deploy.sh`
```bash
- Verifica instalación de Terraform
- Verifica credenciales AWS
- terraform init
- terraform plan
- Pide confirmación
- terraform apply
- Muestra outputs importantes
- Muestra next steps
```

#### `destroy.sh`
```bash
- Advertencia de destrucción
- Lista recursos a eliminar
- Pide confirmación ("destroy")
- terraform destroy
```

## 📊 Flujo de Datos

```
1. Cliente HTTP
   ↓ POST /rooms/message
   
2. NestJS Controller (rooms.controller.ts)
   ↓ Valida DTO
   
3. NestJS Service (rooms.service.ts)
   ↓ SQS SendMessage
   
4. Amazon SQS (gini-dev-rooms-queue)
   ↓ Message stored
   
5. EventBridge Pipe (automático)
   ↓ Poll SQS → Transform → Send
   
6. EventBridge Event Bus
   ↓ Event matched
   
7. EventBridge Rule
   ↓ Route to target
   
8. Lambda Function (index.js)
   ↓ Process event
   
9. CloudWatch Logs
   ✓ Log data visible
```

## 🎯 Archivos Que Debes Crear

### 1. `rooms-poc-backend/.env`

Crear archivo con:
```bash
PORT=3001
NODE_ENV=development

AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key

ROOMS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/XXXXXX/gini-dev-rooms-queue
```

### 2. Credenciales AWS

Configurar en tu shell:
```bash
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_SESSION_TOKEN=your_token  # (opcional)
```

Y también en el archivo `.env` del backend (`rooms-poc-backend/.env`).

## 📝 Archivos de Documentación

| Archivo | Propósito |
|---------|-----------|
| `PROJECT_STRUCTURE.md` | Este archivo - estructura del proyecto |
| `README.md` | Documentación técnica detallada |
| `DEPLOYMENT_GUIDE.md` | Guía paso a paso en español |
| `POC_SUMMARY.md` | Resumen ejecutivo del POC |

## 🧪 Testing Files (a crear)

Archivos sugeridos para testing (no incluidos en POC):

```
data-collection-backend/src/rooms/
├── rooms.controller.spec.ts    # Unit tests del controller
├── rooms.service.spec.ts       # Unit tests del service
└── test/
    └── rooms.e2e-spec.ts       # End-to-end tests
```

## 🔄 Git Status

Archivos listos para commit:

```bash
# Nuevos archivos
rooms-poc-backend/               # Todo el proyecto backend
infra/stacks/rooms-poc/          # Stack de Terraform
DEPLOYMENT_GUIDE.md
POC_SUMMARY.md

# Nota: data-collection-backend/ no fue modificado
```

## 📦 Dependencias Agregadas

```json
{
  "@aws-sdk/client-sqs": "^3.913.0"
}
```

## 🎓 Patterns Implementados

1. **Module Pattern** (NestJS)
   - Controller → Service → External API

2. **DTO Pattern** (Data Transfer Object)
   - Validación con class-validator
   - Documentación con class-transformer

3. **Infrastructure as Code** (Terraform)
   - Modular (cada recurso en su archivo)
   - Reusable (variables y locals)
   - Documented (comments en línea)

4. **Event-Driven Architecture**
   - Async processing con SQS
   - Event routing con EventBridge
   - Serverless compute con Lambda

5. **Clean Code**
   - Nombres descriptivos
   - Comentarios útiles
   - Separación de concerns
   - Single Responsibility Principle

## 🚀 Comandos Rápidos

```bash
# Instalar dependencias
cd rooms-poc-backend && npm install

# Desplegar infraestructura
cd infra/stacks/rooms-poc && ./deploy.sh

# Iniciar backend
cd rooms-poc-backend && npm run start:dev

# Probar endpoint
curl -X POST http://localhost:3001/rooms/message \
  -H "Content-Type: application/json" \
  -d '{"email1":"a@b.com","email2":"c@d.com","roomId":"123"}'

# Ver logs
aws logs tail /aws/lambda/gini-dev-rooms-processor --follow

# Destruir infraestructura
cd infra/stacks/rooms-poc && ./destroy.sh
```

---

**📌 Nota**: Los archivos marcados con ✨ son completamente nuevos.
Los archivos marcados con ✏️ fueron modificados mínimamente.

