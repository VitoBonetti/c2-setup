import sys
import ipaddress

data = open(sys.argv[1],'r').read().splitlines()
gone = list()
for ip in data:
    octets = ip.split(".")
    if octets[0] == "10" or octets[0] == "172": # Fix this if needed for another network type
        firsttwo = ".".join(octets[0:2])
        if firsttwo in gone:
            continue
        gone.append(firsttwo)
        print("sudo ip route add " + firsttwo + ".0.0/16 dev ligolo")
