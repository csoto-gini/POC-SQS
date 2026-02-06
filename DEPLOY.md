# 📖 Guía Completa de Despliegue - Rooms POC

## 📋 Requisitos Previos

- Node.js 20+
- Terraform instalado
- AWS CLI configurado
- Credenciales de AWS con permisos para: SQS, EventBridge, Lambda, IAM

## 🎯 Paso a Paso Detallado

### Paso 1: Preparar el Backend

```bash
# Navegar al backend
cd backend

# Instalar dependencias
npm install
```

### Paso 2: Configurar Variables de Entorno

Crear archivo `backend/.env`:

```bash
# Server Configuration
PORT=3001
NODE_ENV=development

# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Rooms POC - SQS Configuration
# Dejar vacío por ahora - lo llenaremos después del deploy de Terraform
ROOMS_QUEUE_URL=
```

**⚠️ IMPORTANTE**: Reemplaza las credenciales de ejemplo con tus credenciales reales de AWS.

### Paso 3: Desplegar Infraestructura con Terraform

```bash
# Navegar a la carpeta de infraestructura
cd ../infra

# Configurar credenciales AWS para Terraform
export AWS_ACCESS_KEY_ID=tu_access_key
export AWS_SECRET_ACCESS_KEY=tu_secret_key

# Opción A: Usar el script automatizado (recomendado)
./deploy.sh

# Opción B: Manual
terraform init -backend-config=backend.tfbackend
terraform plan
terraform apply
```

El deploy creará:
- ✅ SQS Queue (cola principal)
- ✅ SQS DLQ (dead letter queue)
- ✅ EventBridge Event Bus
- ✅ EventBridge Pipe (conexión SQS → EventBridge)
- ✅ EventBridge Rule (ruteo de eventos)
- ✅ Lambda Function (procesador)
- ✅ IAM Roles y Policies
- ✅ CloudWatch Log Group

**Tiempo estimado**: 2-3 minutos

### Paso 4: Obtener el Queue URL

Después de que Terraform termine exitosamente:

```bash
# Ver todos los outputs
terraform output

# O específicamente el Queue URL
terraform output sqs_queue_url
```

Verás algo como:
```
"https://sqs.us-east-1.amazonaws.com/937623188014/gini-dev-rooms-queue"
```

**Copia este URL** (sin las comillas).

### Paso 5: Actualizar el .env del Backend

Edita `backend/.env` y agrega el Queue URL:

```bash
# Rooms POC - SQS Configuration
ROOMS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/937623188014/gini-dev-rooms-queue
```

### Paso 6: Iniciar el Backend

```bash
# Navegar al backend
cd ../backend

# Modo desarrollo (recomendado para POC)
npm run start:dev

# O modo producción
npm run build
npm run start:prod
```

Deberías ver:

```
╔════════════════════════════════════════════════════════╗
║         Rooms POC Backend - Running                   ║
╚════════════════════════════════════════════════════════╝

🚀 Server is running on: http://localhost:3001
📚 Swagger documentation: http://localhost:3001/api

Available endpoints:
  POST http://localhost:3001/rooms/message
```

### Paso 7: Probar el Endpoint

#### Con cURL:

```bash
curl -X POST http://localhost:3001/rooms/message \
  -H "Content-Type: application/json" \
  -d '{
    "email1": "usuario1@ejemplo.com",
    "email2": "usuario2@ejemplo.com",
    "roomId": "sala-prueba-123"
  }'
```

#### Respuesta esperada:

```json
{
  "success": true,
  "messageId": "12345-abcde-67890-fghij",
  "data": {
    "email1": "usuario1@ejemplo.com",
    "email2": "usuario2@ejemplo.com",
    "roomId": "sala-prueba-123",
    "timestamp": "2026-02-06T12:34:56.789Z"
  }
}
```

#### Con Postman/Insomnia:

- **Método**: POST
- **URL**: `http://localhost:3001/rooms/message`
- **Headers**: `Content-Type: application/json`
- **Body**:

```json
{
  "email1": "usuario1@ejemplo.com",
  "email2": "usuario2@ejemplo.com",
  "roomId": "sala-prueba-123"
}
```

### Paso 8: Verificar Logs de Lambda

```bash
# Ver logs en tiempo real
aws logs tail /aws/lambda/gini-dev-rooms-processor --follow
```

Deberías ver:

```
=== Room Message Lambda Handler Started ===
Event received: {...}
=== Room Message Details ===
Email 1: usuario1@ejemplo.com
Email 2: usuario2@ejemplo.com
Room ID: sala-prueba-123
Timestamp: 2026-02-06T12:34:56.789Z
===========================
```

## ✅ Verificación Completa

### 1. Verificar SQS Queue

```bash
aws sqs get-queue-attributes \
  --queue-url <tu-queue-url> \
  --attribute-names ApproximateNumberOfMessages \
  --region us-east-1
```

### 2. Verificar EventBridge Pipe

```bash
aws pipes list-pipes --region us-east-1
```

Busca: `gini-dev-rooms-pipe` con estado `RUNNING`

### 3. Verificar Lambda

```bash
aws lambda get-function \
  --function-name gini-dev-rooms-processor \
  --region us-east-1
```

### 4. Probar Lambda Directamente

```bash
aws lambda invoke \
  --function-name gini-dev-rooms-processor \
  --payload '{"detail": {"email1": "test@test.com", "email2": "test2@test.com", "roomId": "test-123"}}' \
  response.json
```

## 🔧 Troubleshooting

### Error: "ROOMS_QUEUE_URL is not defined"

**Causa**: Variable faltante en `.env`

**Solución**:
```bash
# Verificar que backend/.env tenga:
ROOMS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/...
```

### Error: "Access Denied" al enviar a SQS

**Causa**: Credenciales incorrectas o sin permisos

**Solución**:
1. Verifica que las credenciales en `backend/.env` sean correctas
2. Verifica que el usuario IAM tenga permisos de SQS:
   ```json
   {
     "Effect": "Allow",
     "Action": ["sqs:SendMessage"],
     "Resource": "*"
   }
   ```

### La Lambda no se ejecuta

**Verificar**:

1. **SQS tiene mensajes?**
   ```bash
   aws sqs get-queue-attributes \
     --queue-url <queue-url> \
     --attribute-names ApproximateNumberOfMessages
   ```

2. **EventBridge Pipe está activo?**
   ```bash
   aws pipes list-pipes
   # Buscar estado: RUNNING
   ```

3. **Lambda tiene permisos?**
   - Revisar IAM Role en AWS Console
   - Verificar que EventBridge tenga permiso para invocar Lambda

4. **CloudWatch Logs**
   ```bash
   aws logs tail /aws/lambda/gini-dev-rooms-processor --follow
   ```

### Backend no inicia

**Verificar**:

1. **Node modules instalados**
   ```bash
   cd backend
   npm install
   ```

2. **Archivo .env existe**
   ```bash
   ls -la backend/.env
   ```

3. **Puerto 3001 no está ocupado**
   ```bash
   lsof -i :3001
   # Si está ocupado, cambiar PORT en .env
   ```

### Terraform errors

**Error: Backend configuration**

```bash
cd infra
terraform init -backend-config=backend.tfbackend -reconfigure
```

**Error: State lock**

```bash
# Si quedó bloqueado
terraform force-unlock <LOCK_ID>
```

## 🧹 Limpiar Todo

Cuando termines de probar:

```bash
# Navegar a infraestructura
cd infra

# Opción A: Con script
./destroy.sh

# Opción B: Manual
terraform destroy
```

**⚠️ ADVERTENCIA**: Esto eliminará TODOS los recursos de AWS creados.

## 📊 Checklist de Despliegue

- [ ] Node.js 20+ instalado
- [ ] Terraform instalado
- [ ] AWS CLI configurado
- [ ] Credenciales AWS obtenidas
- [ ] `backend/.env` creado con credenciales
- [ ] `npm install` ejecutado
- [ ] Infraestructura desplegada (`terraform apply`)
- [ ] Queue URL copiado a `.env`
- [ ] Backend iniciado (`npm run start:dev`)
- [ ] Endpoint probado con cURL
- [ ] Lambda logs verificados en CloudWatch

## 🎓 Entendiendo el Flujo

1. **Cliente** → Envía POST a `/rooms/message`
2. **NestJS Controller** → Valida datos (DTO)
3. **NestJS Service** → Envía mensaje a SQS
4. **Amazon SQS** → Almacena mensaje
5. **EventBridge Pipe** → Lee de SQS automáticamente
6. **EventBridge Event Bus** → Recibe evento transformado
7. **EventBridge Rule** → Filtra y rutea evento
8. **Lambda Function** → Procesa evento y registra en logs
9. **CloudWatch Logs** → Almacena logs para revisión

## 💰 Costos Esperados

Para este POC con volumen bajo:

| Servicio | Free Tier | Costo POC |
|----------|-----------|-----------|
| SQS | 1M requests/mes | $0.00 |
| EventBridge | Incluido | $0.00 |
| Lambda | 1M requests/mes | $0.00 |
| CloudWatch Logs | 5GB/mes | $0.00 |
| **TOTAL** | | **$0.00** ✅ |

## 🔐 Seguridad

**Implementado:**
- ✅ IAM Roles con permisos mínimos
- ✅ SQS Queue Policies restrictivas
- ✅ Validación de datos en backend
- ✅ Dead Letter Queue para mensajes fallidos

**Para Producción:**
- ⏳ Autenticación en endpoint (JWT/Cognito)
- ⏳ Encriptación en reposo (KMS)
- ⏳ VPC para Lambda
- ⏳ WAF para API
- ⏳ Secrets Manager para credenciales

## 📞 Próximos Pasos

Una vez que el POC funcione:

1. **Implementar lógica real** en Lambda (reemplazar logs)
2. **Agregar autenticación** al endpoint
3. **Agregar tests** unitarios e integración
4. **Configurar CI/CD** para deploy automatizado
5. **Agregar monitoring** y alertas
6. **Documentar API** con Swagger

---

**¿Listo?** Comienza con el Paso 1 y en 15 minutos tendrás todo funcionando. 🚀

