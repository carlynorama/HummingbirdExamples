#!/bin/sh

MY_PORT="8080"

separate () {
sleep 2s
echo -e "\n---------------------\n" 
}

curl -i "http://localhost:$MY_PORT/ping"
separate 
curl -i "http://localhost:$MY_PORT/hello"
separate  
curl -i "http://localhost:$MY_PORT/goodbye"

separate 
curl -i "http://localhost:$MY_PORT/files/putonethingafter"
separate 
curl -i "http://localhost:$MY_PORT/doublewild/put/anything/I/want"

separate
curl -i "http://localhost:$MY_PORT/user/8675309"
separate
curl -i "http://localhost:$MY_PORT/user/8675309/Jenny"

separate
curl -i "http://localhost:$MY_PORT/img/non-bunny.jpg"
separate
curl -i "http://localhost:$MY_PORT/img/bunny.jpg"

separate
curl -i "http://localhost:$MY_PORT/query?id=35.53&message=hello%20with%20spaces"

separate
curl -i "http://localhost:$MY_PORT/circus"
separate
curl -i "http://localhost:$MY_PORT/circus/peanuts"
separate
curl -i "http://localhost:$MY_PORT/circus/clowns"
separate
curl -i "http://localhost:$MY_PORT/circus/clowns/anythingcanbeanidforthis"

separate 
curl -i "http://localhost:$MY_PORT/encodable"

separate 
curl -i -X POST localhost:$MY_PORT/decodable/default -d'{"number":12,"phrase":"are you going to go my way"}'
separate 
curl -i -X POST localhost:$MY_PORT/decodable/default -d'{"number":14}'

separate 
curl -i -X POST 'http://localhost:8080/decodable/form' -H 'Content-Type: application/x-www-form-urlencoded' --data-raw 'number=36&phrase=message%20string'
separate 
curl -i -X POST 'http://localhost:8080/decodable/form' -H 'Content-Type: application/x-www-form-urlencoded' --data-raw 'number=36&phrase'