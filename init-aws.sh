#!/bin/bash 

# Variables del ec2 y s3
BUCKET_NAME="bucket-ahau-yucatan"
EC2_INSTANCE_NAME="FEMEC_Eres_Todo_Un_Cloud_Pentester_By_AHAU"
SECURITY_GROUP_NAME="default"
VPC_ID="vpc-12345678" 

echo "[*] Creando bucket secreto en LocalStack..."
awslocal s3 mb s3://$BUCKET_NAME

# Credenciales expuestas en el bucket y otras pistas 

echo "[*] Creando archivo users.txt y subiéndolo al bucket..."
echo "- AWS_DEFAULT_REGION=us-east-1" > users.txt
echo "- AWS_ACCESS_KEY_ID=AKIAAHAU7EXAMPLE12345" >> users.txt
echo "- AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7AHAUENG/bPxRfiCYEXAMPLEKEY" >> users.txt
echo "- Notas personales: Validar el nombre y de la instancia EC2, alguien hizo cambios y no aviso, es un nombre raro, confirmar con el administrador Eduardo L que sucedio." >> users.txt
echo "- NO OLVIDAR Consultar con el siguiente comando:" >> users.txt
awslocal s3 cp users.txt s3://$BUCKET_NAME/

# Verificar si el grupo de seguridad 'default' ya existe
SECURITY_GROUP_ID=$(awslocal ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME --query 'SecurityGroups[0].GroupId' --output text)

if [ "$SECURITY_GROUP_ID" == "None" ]; then
    echo "[*] Creando grupo de seguridad..."
    SECURITY_GROUP_ID=$(awslocal ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Grupo de seguridad predeterminado" --vpc-id $VPC_ID --output text)
    echo "[*] Grupo de seguridad creado con ID: $SECURITY_GROUP_ID"
else
    echo "[*] El grupo de seguridad '$SECURITY_GROUP_NAME' ya existe con ID: $SECURITY_GROUP_ID"
fi

# Verificar si la subred existe y obtener su ID
SUBNET_ID=$(awslocal ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text)

if [ "$SUBNET_ID" == "None" ]; then
    echo "[*] Creando una subred predeterminada..."
    SUBNET_ID=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.0.0/24 --availability-zone us-east-1a --output text)
    echo "[*] Subred creada con ID: $SUBNET_ID"
else
    echo "[*] Subred existente con ID: $SUBNET_ID"
fi

echo "[*] Creando instancia EC2..."

# Crear la instancia EC2 el nombre es la bandera
INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-12345678 \
    --count 1 \
    --instance-type t2.micro \
    --key-name my-key \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=FEMEC_Eres_Todo_Un_Cloud_Pentester_By_AHAU}]" \
    --query 'Instances[0].InstanceId' --output text)

# Verificar si la creación de la instancia fue exitosa
if [ $? -ne 0 ]; then
    echo "[!] Error al crear la instancia EC2."
    exit 1
fi

echo "[*] Instancia EC2 creada con ID: $INSTANCE_ID"

echo "[*] Esperando que la instancia EC2 esté en estado running..."
awslocal ec2 wait instance-running --instance-ids $INSTANCE_ID     

# Verificar el estado de la instancia
INSTANCE_STATUS=$(awslocal ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name' --output text)

if [ "$INSTANCE_STATUS" != "running" ]; then
    echo "[!] La instancia EC2 no está en estado 'running'. Estado actual: $INSTANCE_STATUS"
    exit 1
fi

echo "[*] Instancia EC2 está en estado running."

echo "[*] Proceso completado."
