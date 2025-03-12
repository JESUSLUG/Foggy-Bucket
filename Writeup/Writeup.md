#### **Paso 1**
- Accede a la aplicación en `http://34.51.13.20:8080/`.
- Observa que hay un formulario que permite ingresar una URL y verificar su contenido.
- Este ultimo es vulnerable a Server-Side Request Forgery (SSRF)
- En el URL checker, ponermos http://169.254.169.254/latest/meta-data/ lo que comunmente es el vector de entrada de esta vuln.
- Al acceder nos da la siguiente pista
  
  ![image](https://github.com/user-attachments/assets/07ee8a90-8731-41e3-9f2c-895f4c3673f4)



#### **Paso 2**
- Vemos que nos dice que hay un bucket, en "Bucket": "bucket-ahau-yucatan/users.txt
- Este se aloja en el puerto 4566, en especifico http://34.51.13.20:4566/bucket-ahau-yucatan/users.txt
- al acceder vemos estas credenciales

![image](https://github.com/user-attachments/assets/bf965be2-8bca-451a-a51a-0b0b6c6d34fa)


#### **Paso 3**
- Tenemos que tener el aws cli en nuestra terminal
- vemos que si le tiramos un
  ```bash
  aws --endpoint-url=http://34.51.13.20:4566 s3 ls
  ```
  
![image](https://github.com/user-attachments/assets/0ccbea3b-3ea0-42ad-8dfd-a44d76ce885a)


### **Paso 4**
- Solo revisamos el mismo archivo que encontramos hace rato con un ls
```bash
bucket-ahau-yucatan
```

![image](https://github.com/user-attachments/assets/912fb263-5ec6-4a48-b5d9-93af27453da6)


### **Paso 5**  
- Ver las instancias EC2 ejecutando el siguiente comando:  

   ```bash
   aws --endpoint-url=http://34.51.13.20:4566 ec2 describe-instances \
     --query "Reservations[*].Instances[*].Tags[?Key=='Name'].Value" \
     --output text
   ```

   ![image](https://github.com/user-attachments/assets/caf53d86-af3c-43b6-b8be-fe390e4eab4f)


By M0r0k0
