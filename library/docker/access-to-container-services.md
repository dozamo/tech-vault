## Access to Container Services

```bash
docker images

# start a Container and also run Nginx
# map the port of Host and the port of Container with [-p xxx:xxx]
docker run -t -d -p 5000:80 $(hostname)/001-ubuntu-nginx /usr/sbin/nginx -g "daemon off;" 

docker ps

 # create a test page

root@dlp:~# docker exec 3b04351142ec /bin/bash -c 'echo "Nginx en puerto 5000" > /var/www/html/index.html'
# verify it works normally

root@dlp:~# curl localhost:5000
Nginx en puerto 5000
```