# ban_attacker_ip

Get the ssh login attackers ips and add them to firewall. Each attack banned for five minutes. So if an ip do more attacks, it will be baned (five * attack count) minutes.

It's works on Centos 7.

# Usage

make executable for root

    chmod u+x path_to_/banip.sh
 
add to cron (run it every 5 min)

    */5  *  *  *  *  path_to_/banip.sh
