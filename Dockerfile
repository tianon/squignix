FROM nginx:alpine

# this variable controls the directory parameter of "proxy_cache_path" (https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache_path)
ENV SQUIGNIX_CACHE_PATH /var/cache/nginx
# this variable controls the "max_size" parameter of "proxy_cache_path" (https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache_path)
ENV SQUIGNIX_CACHE_MAX_SIZE 800m

RUN set -eux; \
# pre-seed our templating
	mkdir /etc/nginx/templates; \
	echo 'proxy_cache_path ${SQUIGNIX_CACHE_PATH} levels=1:2 keys_zone=my_cache:10m inactive=365d max_size=${SQUIGNIX_CACHE_MAX_SIZE} use_temp_path=off;' > /etc/nginx/templates/squignix-generated.include.template; \
# pre-generate with the defaults for compatibility with read-only containers
	envsubst '${SQUIGNIX_CACHE_PATH} ${SQUIGNIX_CACHE_MAX_SIZE}' < /etc/nginx/templates/squignix-generated.include.template | tee /etc/nginx/conf.d/squignix-generated.include; \
	\
# use more workers
	sed -ri -e 's/^worker_processes.*$/worker_processes auto;/g' /etc/nginx/nginx.conf; \
	grep -n 'worker_processes auto' /etc/nginx/nginx.conf; \
	\
# naming this to match https://github.com/nginxinc/docker-nginx/commit/b053826f5ddc6cccd43ada260c8077744319363d (but in a way that supports a read-only container)
	mkdir /etc/nginx/stream-conf.d; \
	{ \
		echo; \
		echo 'stream {'; \
		echo '  include /etc/nginx/stream-conf.d/*.conf;'; \
		echo '}'; \
	} >> /etc/nginx/nginx.conf; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		ppc64le | s390x) echo 'server_names_hash_bucket_size 64;' >> "/etc/nginx/conf.d/$apkArch.conf" ;; \
	esac

COPY http.conf /etc/nginx/conf.d/default.conf
COPY stream-tls.conf /etc/nginx/stream-conf.d/tls.conf

RUN nginx-debug -t

EXPOSE 80 443 11371
