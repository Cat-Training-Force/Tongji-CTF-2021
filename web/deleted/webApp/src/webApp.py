from flask import Flask, request
from flask_cors import CORS
import html
import os


flag = open('flag', 'r')
os.remove('flag')

sourceFile = open('webApp.py', 'r')
sourceCode = html.escape(sourceFile.read())
sourceFile.close()

app = Flask(__name__)
CORS(app, supports_credentials=True)


@app.route('/', methods=['GET'])
def index():
    return "Flag is deleted. You won't get it!"


@app.route('/source', methods=['GET'])
def getSource():
    return '<pre><code>' + sourceCode + '</code></pre>' 


@app.route('/getfile', methods=['GET'])
def getFile():
    fileName = request.args.get('file', '')
    try:
        with open(fileName, 'r') as file:
            return '<pre>' + html.escape(file.read()) + '</pre>'
    except:
        return "Error opening/reading file"


if __name__ == '__main__':
    app.run()

