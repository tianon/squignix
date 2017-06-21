# Why?

I'm not a fan of configuring [Squid](http://www.squid-cache.org/), and the NGINX configuration format has always seemed simpler.

When I saw the cute hack of doing `proxy_pass http://$host;`, I couldn't resist trying it, especially since I haven't been 100% satisfied with [Apt-Cacher NG](https://www.unix-ag.uni-kl.de/~bloch/acng/) either.

The configuration I've ended up with is probably a tad overaggressive about caching things (I haven't been testing it for very long, after all!), but it's speeding things up, so I'm happy with it anyhow!

# Usage

This is how I use it -- your mileage may vary.

```console
$ docker volume create \
	--driver local \
	--opt type=tmpfs \
	--opt device=tmpfs \
	--opt o=size=1048576k \
	squignix
```

(The size of this `tmpfs` controls how much RAM will be used for cache and also how much cache will be available.  If having the cache in RAM isn't your thing and you still want an upper limit, you'll need to modify the NGINX configuration to add `max_size` to the `proxy_cache_path` directive.)

```console
$ docker run -dit --name squignix -v squignix:/var/cache/nginx tianon/squignix
```

Once I've got that running, I add something like this to my [rawdns](https://github.com/tianon/rawdns#readme) configuration:

```json
	"deb.debian.org.": {
		"type": "static",
		"cnames": [ "squignix.docker" ],
		"nameservers": [ "127.0.0.1" ]
	},
	"dl-cdn.alpinelinux.org.": {
		"type": "static",
		"cnames": [ "squignix.docker" ],
		"nameservers": [ "127.0.0.1" ]
	},
	...
```

Since both my host and all my containers are configured to point at rawdns, this works transparently.  There are other ways to accomplish this, but they'll be left as an exercise for the reader.
