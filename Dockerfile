FROM nginx:alpine

RUN set -ex; \
	\
# use more workers
	sed -ri -e 's/^worker_processes.*$/worker_processes auto;/g' /etc/nginx/nginx.conf; \
	grep -n 'worker_processes auto' /etc/nginx/nginx.conf; \
	\
	mkdir /etc/nginx/non-http-conf.d; \
	{ \
		echo; \
		echo 'include /etc/nginx/non-http-conf.d/*.conf;'; \
	} >> /etc/nginx/nginx.conf

COPY http.conf /etc/nginx/conf.d/default.conf
COPY stream.conf /etc/nginx/non-http-conf.d/

RUN nginx-debug -t

EXPOSE 80 443 11371
