global
    log 127.0.0.1 local0
    log 127.0.0.1 local1 notice
    chroot /var/lib/haproxy
    user haproxy
    group haproxy

defaults
    log global
    mode http
    option forwardfor
    option http-server-close
    option httplog
    option dontlognull
    retries 3
    redispatch
    maxconn 2048
    contimeout 5000
    clitimeout 50000
    srvtimeout 50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

listen stats :1936
   stats enable   
   stats scope www-http
   stats scope www-backend
   stats uri /
   stats realm Haproxy\ Statistics
   stats auth user:password

frontend www-http
    bind haproxy_www_public_IP:80
    reqadd X-Forwarded-Proto:\ http
    default_backend www-backend

frontend www-https
   bind haproxy_www_public_IP:443 ssl crt /etc/ssl/private/example.com.pem
   reqadd X-Forwarded-Proto:\ https
   default_backend www-backend

backend www-backend
    redirect scheme https if !{ ssl_fc }
{{range .}}     server {{.Name}} {{.Ip}}:{{.Port}} check maxconn 32
{{end}}
