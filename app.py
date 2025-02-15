from flask import Flask, request, Response
import requests

app = Flask(__name__)

    # Ignorar no funciona, dejemos que devuelva las credenciales reales .. 

AWS_CREDENTIALS = """AWS_CREDENTIALS = { 
    "Bucket": "secrect-bucket-challenge/user.txt",
    "AccessKeyId": "AKxxxxxxxxx",
    "SecretAccessKey": "wJxxxxxxxxxxx",
    "Token": "test",
    "Region": "us-east-1"
}"""

@app.route('/')
def home():
    return """
    <h1>URL Checker</h1>
    <form action="/check" method="GET">
        <input type="url" name="url" placeholder="Enter URL to check">
        <input type="submit" value="Check">
    </form>
    """

@app.route('/check')
def check_url():
    url = request.args.get('url')
    if not url:
        return "Please provide a URL", 400

    # Si la URL ingresada es la específica, devolvemos las credenciales
    if url == "http://34.51.13.20:8080/latest/meta-data/iam/security-credentials/":
        return Response(AWS_CREDENTIALS, mimetype="text/plain")

    # Para otras URLs, hacer la petición real
    try:
        response = requests.get(url)
        return response.text
    except Exception as e:
        return str(e), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
