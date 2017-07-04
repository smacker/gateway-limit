docker run --rm \
           -it \
           -e JWT_SECRET=dev \
           -v `pwd`/nginx.conf:/nginx.conf \
           -v `pwd`/bearer.lua:/bearer.lua \
           -p 9999:8080 \
           ubergarm/openresty-nginx-jwt
