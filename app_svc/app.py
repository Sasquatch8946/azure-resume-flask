from flask import Flask, render_template
import requests
import os
import logging
import sys

app = Flask(__name__)

@app.route("/read_db")
def getCounter():
    FUNCTION_URL = os.getenv("FUNCTION_URL")
    res = requests.get(url=FUNCTION_URL)
    resJSON = res.json()
    return resJSON, res.status_code, {'Cache-Control': 'no-store'}

@app.route("/")
def index():
    return render_template("index.html")


if __name__ == '__main__':
    app.run()
