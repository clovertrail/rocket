import ConfigParser
from flask import Flask, render_template, request
import MySQLdb as mysql

cf = ConfigParser.ConfigParser()
cf.read("config/common.ini")
db_host = cf.get("db","db_host")
db_port = cf.get("db","db_port")
db_user = cf.get("db","db_user")
db_pass = cf.get("db","db_pass")
db_database = cf.get("db","db_database")

db = mysql.connect(user=db_user,passwd=db_pass,db=db_database,host=db_host)
db.autocommit(True)
cur = db.cursor()
app = Flask(__name__)
import json

tmp_time=0
@app.route('/')
def index():
    return render_template('index.html')

def data1():
    sql = 'select * from httpaccess'
    cur.execute(sql)
    arr = []
    for i in cur.fetchall():
        arr.append([i[1]*1000,i[0]])
    return json.dumps(arr)

@app.route('/data')
def data():
    global tmp_time
    if tmp_time>0:
        sql = 'select time_stamp,response_time from httpaccess where time_stamp>%s' % (tmp_time/1000)
    else:
        sql = 'select time_stamp,response_time from httpaccess'
    cur.execute(sql)
    arr = []
    for i in cur.fetchall():
        arr.append([i[0],i[1]])
    if len(arr)>0:
        tmp_time = arr[-1][0]
    return json.dumps(arr)

if __name__=='__main__':
    app.run(host='0.0.0.0',port=9092,debug=True)
