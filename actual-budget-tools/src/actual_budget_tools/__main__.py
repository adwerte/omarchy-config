from flask import Flask, send_from_directory, request
import os
import argparse
import glob

parser = argparse.ArgumentParser()
parser.add_argument("backup_folder")
args = parser.parse_args()
backup_folder = os.path.abspath(args.backup_folder)

app = Flask(__name__)

@app.route('/')
def get_filelist():
    path = backup_folder +   "/**/*" 
    files = glob.glob(path, recursive=True)
    output = []
    for file in files:
        if not os.path.isfile(file):
            continue
        print(file)
        output.append(file.replace(args.backup_folder, ""))
    return output

@app.route('/download')
def download_file():
    name = request.args['file']
    return send_from_directory(backup_folder, name)
    
def main():
    app.run(host = '0.0.0.0', port=5001, debug=False)
