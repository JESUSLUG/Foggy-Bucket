from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Credenciales de AWS (las mismas que se estan utilizando en LocalStack)
AWS_CREDENTIALS = {
    "AccessKeyId": "test",
    "SecretAccessKey": "test",
    "Token": "test",
    "Region": "us-east-1"
}

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
    
    try:
        response = requests.get(url)
        return response.text
    except Exception as e:
        return str(e), 500

# Endpoint que simula el servicio de metadata de AWS
@app.route('/latest/meta-data/iam/security-credentials/')
def metadata():
    return jsonify(AWS_CREDENTIALS)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
