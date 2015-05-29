#!/bin/bash

# Fahri Aydos (http://aydos.com) 2015 05 28

# FOR CENTOS
# NOT TESTED YET

# iplist dosyası yoksa oluşturur
touch /tmp/iplist

# bir tane olanları iptables/firewall'dan çıkarır
# birden fazla olanlar iptables/firewall'da kalmaya devam eder
#sort iplist | uniq -c | awk '{if($1==1) print $2}' | xargs -I ip iptables -D INPUT -s ip -j DROP
sort /tmp/iplist | uniq -c | awk '{if($1==1) print $2}' | xargs -I IP firewall-cmd --zone=public --remove-rich-rule='rule family="ipv4" source address="IP" reject'

# her ip'den bir tanesini siler
sort /tmp/iplist -u | xargs -I ip sed -i '0,/'ip'/{//d;}' iplist

# son 5 dakika içinde yapılan atakları dosyaya yazar
# root'a yapılan ataklar (root login'i kapatılmalı)
sed -n "/^$(date --date='5 minutes ago' '+%b %d %H:')/,\$p" /var/log/secure | grep "Failed.*root" | awk '{print $11}' > newips
# olmayan kullanıcılara yapılan ataklar (admin, mysqladmin gibi)
sed -n "/^$(date --date='5 minutes ago' '+%b %d %H:')/,\$p" /var/log/secure | grep "Failed.*invalid" | awk '{print $13}' >> newips

# yeni gelen ip'leri iptables/firewall'a ekler
#sort newips -u | xargs -I ip iptables -A INPUT -s ip -j DROP
sort /tmp/newips -u | xargs -I IP firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="IP" reject'

# yeni ip'leri listeye ekler
cat /tmp/newips >> /tmp/iplist
#rm -rf newips

# iptables'ı kaydeder
#service iptables save
systemctl restart firewalld.service
