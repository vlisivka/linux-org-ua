lynx -source "http://linux.org.ua/cgi-bin/yabb/yabb2rss?group=novyny&body=yes" >linux.org.ua.rss && \
 /var/www/vhosts/linux.org.ua/bin/xslt/xslt.run "rss-view-full.xsl" "linux.org.ua.rss" \
  >../htdocs/rss/linux.org.ua.rss.html
  
lynx -source "http://linux.org.ua/cgi-bin/yabb/yabb2rss?group=novyny" >linux.org.ua-short.rss && \
 /var/www/vhosts/linux.org.ua/bin/xslt/xslt.run "rss-view-full.xsl" "linux.org.ua-short.rss" \
  >../htdocs/rss/linux.org.ua-short.rss.html
