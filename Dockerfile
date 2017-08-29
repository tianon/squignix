FROM nginx:alpine

RUN set -ex; \
	mkdir /etc/nginx/non-http-conf.d; \
	{ \
		echo; \
		echo 'include /etc/nginx/non-http-conf.d/*.conf;'; \
	} >> /etc/nginx/nginx.conf

COPY http.conf /etc/nginx/conf.d/default.conf
COPY stream.conf /etc/nginx/non-http-conf.d/

EXPOSE 80 443 11371
