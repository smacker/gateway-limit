Limit 1 r/s, burst 2 r/s

```
$ ./run.sh
172.17.0.1 - - [04/Jul/2017:11:28:19 +0000] "GET /secure/ HTTP/1.1" 200 39 "-" "Go-http-client/1.1" "-"
172.17.0.1 - - [04/Jul/2017:11:28:19 +0000] "GET /secure/ HTTP/1.1" 503 219 "-" "Go-http-client/1.1" "-"
172.17.0.1 - - [04/Jul/2017:11:28:19 +0000] "GET /secure/ HTTP/1.1" 503 219 "-" "Go-http-client/1.1" "-"
172.17.0.1 - - [04/Jul/2017:11:28:20 +0000] "GET /secure/ HTTP/1.1" 200 39 "-" "Go-http-client/1.1" "-"
172.17.0.1 - - [04/Jul/2017:11:28:21 +0000] "GET /secure/ HTTP/1.1" 200 39 "-" "Go-http-client/1.1" "-"

$ go run test.go
200
503
503
200
200
```
