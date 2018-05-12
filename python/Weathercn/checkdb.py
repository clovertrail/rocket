import MySQLdb as mysql

db = mysql.connect(user='root',passwd='Hackathon@2017',db='weathercn',host='localhost')
db.autocommit(True)
cur = db.cursor()
sql = 'select time_stamp,response_time from httpaccess'
cur.execute(sql)
arr = []
for i in cur.fetchall():
    arr.append([i[1], i[0]])
if len(arr) > 0:
    print arr[-1]
