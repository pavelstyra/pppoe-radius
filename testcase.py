#!/usr/bin/python
import paramiko, subprocess, time
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
# connecting to client1
client.connect('172.16.0.20', username='vagrant', password='vagrant')

def disconnect():
  if client:
    client.close()

def createuser(inuser):
  user = inuser
  line0 = "insert into radcheck (username, attribute, op, value) VALUES ('%s', 'Cleartext-Password', ':=', 'testpass');" % user
  line1 = "insert into radreply (username, attribute, op, value) VALUES ('%s', 'Framed-Protocol', ':=', 'PPP');" % user
  line2 = "insert into radreply (username, attribute, op, value) VALUES ('%s', 'Service-Type', ':=', 'Framed-User');" % user
  line3 = "insert into radreply (username, attribute, op, value) VALUES ('%s', 'Framed-Compression', ':=', 'Van-Jacobsen-TCP-IP');" % user
  line4 = "insert into radreply (username, attribute, op, value) VALUES ('%s', 'Framed-MTU', ':=', '1500');" % user
  createuser = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  createuser[4] = line0
  attr1 = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  attr2 = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  attr3 = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  attr4 = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  attr1[4] = line1
  attr2[4] = line2
  attr3[4] = line3
  attr4[4] = line4
  subprocess.call(createuser)
  subprocess.call(attr1)
  subprocess.call(attr2)
  subprocess.call(attr3)
  subprocess.call(attr4)

def removeuser(outuser):
  user = outuser
  line0 = "delete from radcheck where username = '%s';" % user
  line1 = "delete from radreply where username = '%s';" % user
  removeuser = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  removeattr = ["mysql", "-uroot", "-pslackware", "-e", "", "radius"]
  removeuser[4] = line0
  removeattr[4] = line1
  subprocess.call(removeuser)
  subprocess.call(removeattr)

# in case user exists remove it first
removeuser('user1')
removeuser('user2')
createuser('user1')
createuser('user2')
print "[ server* ] Added user1 and user2 to RADIUS"

# in case tunnel is up shutdown it first
stdin, stdout, stderr = client.exec_command("sudo poff myisp && sleep 5; pon myisp")
time.sleep(10)
stdin, stdout, stderr = client.exec_command("sudo ip route del default via 10.0.2.2")
stdin, stdout, stderr = client.exec_command("sudo ip route del default via 0.0.0.0")
stdin, stdout, stderr = client.exec_command("sudo ip route add default via 10.33.3.1")
stdin, stdout, stderr = client.exec_command("sudo ifconfig | grep ppp")
line = stdout.read()
if 'ppp0' in line:
  print "[ client1 ] Point-to-point link is up"
else:
  print "[ client1 ] Test failed. Point-to-point link is down"
stdin, stdout, stderr = client.exec_command("sudo ping -I ppp0 -c 4 8.8.8.8")
pingresult = stdout.read()
if '0% packet loss' in pingresult:
  print "[ client1 ] Network test succeeded"
else:
  print "[ client1 ] Test failed. Network is unreachable"

disconnect()
# connecting to client2
client.connect('172.16.0.30', username='vagrant', password='vagrant')
# in case tunnel is up shutdown it first
stdin, stdout, stderr = client.exec_command("sudo poff myisp && sleep 5; pon myisp")
time.sleep(10)
stdin, stdout, stderr = client.exec_command("sudo ip route del default via 10.0.2.2")
stdin, stdout, stderr = client.exec_command("sudo ip route del default via 0.0.0.0")
stdin, stdout, stderr = client.exec_command("sudo ip route add default via 10.33.3.1")
stdin, stdout, stderr = client.exec_command("sudo ifconfig | grep ppp")
line = stdout.read()
if 'ppp0' in line:
  print "[ client2 ] Point-to-point link is up"
else:
  print "[ client2 ] Test failed. Point-to-point link is down"
stdin, stdout, stderr = client.exec_command("sudo ping -I ppp0 -c 4 8.8.8.8")
pingresult = stdout.read()
if '0% packet loss' in pingresult:
  print "[ client2 ] Network test succeeded"
else:
  print "[ client2 ] Test failed. Network is unreachable"

removeuser('user1')
print "[ server* ] Removed user1 from RADIUS"
disconnect()
# connecting to client1
client.connect('172.16.0.20', username='vagrant', password='vagrant')
# in case tunnel is up shutdown it first
stdin, stdout, stderr = client.exec_command("sudo poff myisp && sleep 5; pon myisp")
time.sleep(10)
stdin, stdout, stderr = client.exec_command("sudo ip route del default via 10.0.2.2")
stdin, stdout, stderr = client.exec_command("sudo ip route del default via 0.0.0.0")
stdin, stdout, stderr = client.exec_command("sudo ip route add default via 10.33.3.1")
stdin, stdout, stderr = client.exec_command("sudo ifconfig | grep ppp")
line = stdout.read()
if 'ppp0' in line:
  print "[ client1 ] Point-to-point link is up"
else:
  print "[ client1 ] Test failed. Point-to-point link is down"
stdin, stdout, stderr = client.exec_command("sudo ping -I ppp0 -c 4 8.8.8.8")
pingresult = stdout.read()
if '0% packet loss' in pingresult:
  print "[ client1 ] Network test succeeded"
else:
  print "[ client1 ] Test failed. Network is unreachable"
