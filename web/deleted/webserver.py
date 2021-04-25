from flask import Flask, request
from flask_cors import CORS
import os

file = open('flag')
os.remove('flag')

app = Flask(__name__)
CORS(app, supports_credentials=True)

@app.route('/', methods=['GET'])
def getFile():
    fileName = request.args.get('fileName', '')
    newfile = open(fileName)
    line = newfile.readline()
    newfile.close()
    return line

if __name__ == '__main__':
    app.run(host='0.0.0.0', port='8888')
