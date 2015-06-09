#!/bin/bash

# Fahri Aydos (http://aydos.com) 2015 05 28

# FOR CENTOS
# USAGE :
#### make executable for root
# chmod u+x path_to_/banip.sh
#### add to cron (run it every 5 min)
# */5  *  *  *  *  path_to_/banip.sh
#

# iplist dosyası yoksa oluşturur
touch /tmp/iplist

# TÜRKÇE: bir tane olanları iptables/firewall'dan çıkarır
# birden fazla olanlar iptables/firewall'da kalmaya devam eder
# bu sayıyı artırabilirsiniz, böylece mesela 5 defa atak yapmadan bloklanmaz
# ENGLISH: remove ip from iptables/firewall if there is only one
# you can set up higher value if you like ban more serious attackers
#sort iplist | uniq -c | awk '{if($1==1) print $2}' | xargs -I IP iptables -D INPUT -s IP -j DROP
sort /tmp/iplist | uniq -c | awk '{if($1==1) print $2}' | xargs -I IP firewall-cmd --zone=public --remove-rich-rule='rule family="ipv4" source address="IP" reject'

# her ip'den bir tanesini siler
# delete only one copy of ip
sort /tmp/iplist -u | xargs -I ip sed -i '0,/'ip'/{//d;}' /tmp/iplist

# son 5 dakika içinde yapılan atakları dosyaya yazar
# get the attackers ips for last 5 minutes

# root'a yapılan ataklar (root login'i kapatılmalı)
# for root (you must/should disable root login)
sed -n "/^$(date --date='5 minutes ago' '+%b %d %H:')/,\$p" /var/log/secure | grep "Failed.*root" | awk '{print $11}' > /tmp/newips
# olmayan kullanıcılara yapılan ataklar (admin, mysqladmin gibi)
# for non exist users (eg admin, mysqladmin)
sed -n "/^$(date --date='5 minutes ago' '+%b %d %H:')/,\$p" /var/log/secure | grep "Failed.*invalid" | awk '{print $13}' >> /tmp/newips

# yeni gelen ip'leri iptables/firewall'a ekler
# add new ips to iptables/firewall
#sort newips -u | xargs -I ip iptables -A INPUT -s ip -j DROP
sort /tmp/newips -u | xargs -I IP firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="IP" reject'

# yeni ip'leri listeye ekler
# add new ips to the list
cat /tmp/newips >> /tmp/iplist
#rm -rf newips

#iptables'ı kaydeder
#service iptables save
#systemctl restart firewalld.service
