#/bin/bash
#auuthor:alex
#shell for creating grafana dashboard report
filepath=/opt/grafana/report/
date=$(date +%Y-%m-%d-%H:%M)

# dashboard report name
filename_yunwei_ziyuan=运维资源全览-centernode-${date}.pdf

# download grafana dashboard report
wget -q -O ${filepath}${filename_yunwei_ziyuan} "http://172.22.254.57:30868/api/v5/report/viOR-qvnkdasd?apitoken=eyJrIjoiNjRZQjJlT2pKM1h2QVZLbTZWQ0pzMjFJSzdjSVFQUkYiLCJuIjoiZ3JhZmFuYS1yZXBvcnQiLCJpZCI6MX0=&from=now-24h&to=now&var-origin_prometheus=&var-Node=All&var-NameSpace=All&var-Container=All&var-Pod=All"

sleep 30s

# send email
mail -i \
-a ${filepath}${filename_yunwei_ziyuan} \
-s "Grafana监控日报"-`date +%Y-%m-%d-%H:%M` \
-c "21178857@qq.com" ywz0207@163.com < /opt/grafana/logs/send_mail.log 
