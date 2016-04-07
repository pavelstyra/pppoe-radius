# pppoe-radius
**Start provisioning and ssh to server:**
```
vagrant up --provider virtualbox
vagrant ssh server
```

**Start test case sample:**
```
sudo su
/vagrant/testcase.py
```

**Result:**
```
[ server* ] Added user1 and user2 to RADIUS
[ client1 ] Point-to-point link is up
[ client1 ] Network test succeeded
[ client2 ] Point-to-point link is up
[ client2 ] Network test succeeded
[ server* ] Removed user1 from RADIUS
[ client1 ] Test failed. Point-to-point link is down
[ client1 ] Test failed. Network is unreachable
```
