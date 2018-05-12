This project targets to show you how to display dynamic data on webapp through Python(flask) + MySql + HighChart. The example here displays the HTTP response time from WeatherCN in high chart.

# How to run
1. Install curl and mysql locally. Create database 'weathercn'.
2. Specify the db_user and db_pass in config/common.ini
3. Run python weathercn_monitor.py. It will ping weatherCN and save response time to MySQL DB.
4. Run python weathercn_flask_web.py. It will display the web page.
