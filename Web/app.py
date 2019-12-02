import os
from flask import Flask, send_from_directory

app = Flask(__name__, static_folder='static/')

@app.route('/')
def root():
    return send_from_directory(os.path.join('.', 'static'), 'index.html')
    
if __name__ == "__main__":
    app.run(debug=True)