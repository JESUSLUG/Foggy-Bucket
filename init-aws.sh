  GNU nano 4.8                                                                                                        init-aws.sh                                                                                                                  
#!/bin/bash

# Crear un bucket
awslocal s3 mb s3://secret-bucket-challenge

# Crear la flag y subirla al bucket
echo "FLAG{Eres_Todo_Un_Pentester_Cloud_By_AHAU}" > flag.txt
awslocal s3 cp flag.txt s3://secret-bucket-challenge/

echo "Bucket y flag creados exitosamente"
