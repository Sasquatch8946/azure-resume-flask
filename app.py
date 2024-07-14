from flask import Flask, render_template, jsonify
import requests
import json
import os
from dotenv import load_dotenv

if ( os.environ['ENVIRONMENT'] == 'development'):
    print("Loading environment variables from .env file")
    load_dotenv(".env")

FUNCTION_URL = os.getenv("FUNCTION_URL")

app = Flask(__name__)
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0

@app.route("/read_db")
def getCounter():
    functionApi = FUNCTION_URL
    res = requests.get(url=functionApi)
    res.raise_for_status()
    resStr = res.content.decode()
    resJSON = json.loads(resStr)
    return resJSON

@app.route("/")
def index():
    return render_template("index.html")

@app.after_request
def add_header(r):
    r.headers["Cache-Control"] = "no-store"
    return r

if __name__ == '__main__':
    app.run()
