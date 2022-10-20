From haproxytech/kubernetes-ingress:1.8.6 as builder
WORKDIR /usr/src
COPY . .
RUN apk update
RUN apk add build-base lua5.3-dev openssl-dev unzip make 
RUN ./install.sh luaoauth

From haproxytech/kubernetes-ingress:1.8.6
RUN mkdir -p /usr/local/share/lua/5.3/
RUN mkdir -p /usr/local/lib/lua/5.3/
COPY --from=builder /usr/local/share/lua/5.3/ /usr/local/share/lua/5.3/
COPY --from=builder /usr/local/lib/lua/5.3/ /usr/local/lib/lua/5.3/
