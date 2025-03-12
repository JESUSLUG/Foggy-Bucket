from flask import Flask, request, Response
import requests

app = Flask(__name__)

    # Credenciales falsas pero pista para acceder al bucket

AWS_CREDENTIALS = """AWS_CREDENTIALS = { 
    "Bucket": "bucket-ahau-yucatan/users.txt",
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
    if url == "http://169.254.169.254/latest/meta-data/":
        return Response(AWS_CREDENTIALS, mimetype="text/plain")

    # Para otras URLs, hacer la petición real
    try:
        response = requests.get(url)
        return response.text
    except Exception as e:
        return str(e), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
