from flask import Flask, send_from_directory, jsonify
from psycopg2.extras import RealDictCursor # transforms all retrieved rows as a dictionnary
from multiprocessing import Array, Process, Value
from ctypes import c_char, c_wchar
import psycopg2
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
        postgreSQL_select_Query = "SELECT * FROM t_post"
        cursor.execute(postgreSQL_select_Query)
        queryResults = cursor.fetchall()

    except (Exception, psycopg2.Error) as error :
        print ("Error while fetching data from PostgreSQL", error)

    # closing database connection.
    finally:
        if(connection):
            cursor.close()
            connection.close()

    print('returning')
    print(queryResults)
    return queryResults

# ROUTING
app = Flask(__name__, static_folder='static/')
@app.route('/')
def root():
    return send_from_directory(os.path.join('.', 'static'), 'index.html')

@app.route('/data')
def API_BASIC():
    return jsonify(queryDatabase())
    
# main function, simply launching the server
if __name__ == "__main__":
    app.run(debug=True)