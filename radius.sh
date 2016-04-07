#!/bin/bash
debconf-set-selections <<< 'mysql-server mysql-server/root_password password slackware'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password slackware'
apt-get -y install freeradius freeradius-mysql mysql-server freeradius-utils libfreeradius-client-dev libfreeradius-client2
mysql -uroot -pslackware -e 'create database radius;'
mysql -uroot -pslackware -e 'grant all on radius.* to radius@localhost identified by "slackware";'
mysql -uroot -pslackware radius < /etc/freeradius/sql/mysql/schema.sql
mysql -uroot -pslackware radius < /etc/freeradius/sql/mysql/nas.sql

echo '127.0.0.1 promotion' > /etc/radiusclient/servers
# Can't read map file /etc/radiusclient/port-id-map
touch /etc/radiusclient/port-id-map

echo 'client localhost {
ipaddr = 127.0.0.1
secret = promotion
require_message_authenticator = no
nastype = other
}
client localtest {
ipaddr = 127.0.1.1
secret = promotion
require_message_authenticator = no
nastype = other
}' > /etc/freeradius/clients.conf

echo 'sql {
        database = "mysql"
        driver = "rlm_sql_${database}"
        server = "localhost"
        login = "radius"
        password = "slackware"
        radius_db = "radius"
        acct_table1 = "radacct"
        acct_table2 = "radacct"
        postauth_table = "radpostauth"
        authcheck_table = "radcheck"
        authreply_table = "radreply"
        groupcheck_table = "radgroupcheck"
        groupreply_table = "radgroupreply"
        usergroup_table = "radusergroup"
        deletestalesessions = yes
        sqltrace = yes
        sqltracefile = ${logdir}/sqltrace.sql
        num_sql_socks = 5
        connect_failure_retry_delay = 30
        lifetime = 0
        max_queries = 0
        nas_table = "nas"
        $INCLUDE sql/${database}/dialup.conf
}' > /etc/freeradius/sql.conf

sed -i '743d' /etc/freeradius/radiusd.conf
sed -i '743i\        $INCLUDE sql.conf' /etc/freeradius/radiusd.conf

sed -i '177d' /etc/freeradius/sites-enabled/default
sed -i '177i\        sql' /etc/freeradius/sites-enabled/default
sed -i '406d' /etc/freeradius/sites-enabled/default
sed -i '406i\        sql' /etc/freeradius/sites-enabled/default
sed -i '454d' /etc/freeradius/sites-enabled/default
sed -i '454i\        sql' /etc/freeradius/sites-enabled/default
sed -i '475d' /etc/freeradius/sites-enabled/default
sed -i '475i\        sql' /etc/freeradius/sites-enabled/default

systemctl restart freeradius
systemctl start pppoe-server
