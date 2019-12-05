from flask import Flask, send_from_directory, jsonify
from multiprocessing import Array, Process, Value
from collections import namedtuple
from ctypes import c_char, c_wchar
from flask_cors import CORS
import psycopg2
import requests
import time
import os

def queryDatabase():
    # PostegreSQL connection variables
    POSTGRES_URL = "raja.db.elephantsql.com"
    POSTGRES_PORT = "5432"
    POSTGRES_USER = "cjczxqkt"
    POSTGRES_PASSWORD = "VA69fv50J_3JHnNqEOLQ5r7bs1wPQPXS"
    POSTGRES_DB_NAME = "cjczxqkt"

    retVal = 'no data'
    try:
        connection = psycopg2.connect(user=POSTGRES_USER,
                                      password=POSTGRES_PASSWORD,
                                      host=POSTGRES_URL,
                                      port=POSTGRES_PORT,
                                      database=POSTGRES_DB_NAME)
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM t_post")
        retVal = cursor.fetchall()

    except (Exception, psycopg2.Error) as error :
        print ("Error while fetching data from PostgreSQL", error)

    # closing database connection.
    finally:
        if(connection):
            cursor.close()
            connection.close()

    return retVal

# ROUTING
app = Flask(__name__, static_folder='static/')
# cors = CORS(app, resources={r"*": {"origins": "*"}})
CORS(app)

@app.route('/')
def root():
    return send_from_directory(os.path.join('.', 'static'), 'index.html')

@app.route('/data')
def API_BASIC():
    return jsonify(queryDatabase())
    
# main function, simply launching the server
if __name__ == "__main__":
    app.run(debug=True)