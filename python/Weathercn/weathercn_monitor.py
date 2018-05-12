import ConfigParser
import time
import MySQLdb as mysql
import shellutil
import peewee
from peewee import *

cf = ConfigParser.ConfigParser()
cf.read("config/common.ini")
db_host = cf.get("db","db_host")
db_port = cf.get("db","db_port")
db_user = cf.get("db","db_user")
db_pass = cf.get("db","db_pass")
db_database = cf.get("db","db_database")

db = MySQLDatabase(db_database, user=db_user, passwd=db_pass)

class HttpAccess(peewee.Model):
    time_stamp = peewee.IntegerField()
    response_time = peewee.FloatField()
    
    class Meta:
        database = db;

def save_http_ping_to_db():
    (out, err) = shellutil.subp(['curl', '-o', '/dev/null', '-s',
                       '-w', '%{time_total}',
                       'http://geo.weathercn.com/ag/?'])
    if len(err):
        print "Error"
        return
    t = int(time.time())

    try:
        HttpAccess.create_table()
    except peewee.OperationalError:
        pass
        #print "HttpAccess table already exists!"
    print t, out
    httpAccess = HttpAccess(time_stamp=t, response_time=float(out))
    httpAccess.save()

if __name__=="__main__":
    while True:
        time.sleep(1)
        save_http_ping_to_db()
