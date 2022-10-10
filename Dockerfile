ARG CADDY_VERSION
FROM caddy:${CADDY_VERSION}-builder AS builder

# TODO: Cache dirs for faster builds

# --- Cloudflare ---
FROM builder AS cloudflare
RUN --mount=type=cache,target=${GOPATH} \
  xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:${CADDY_VERSION}
COPY --from=cloudflare /usr/bin/caddy /usr/bin/caddy

# --- Route 53 ---
FROM builder AS route53
RUN --mount=type=cache,target=${GOPATH} \
  xcaddy build \
    --with github.com/caddy-dns/route53

FROM caddy:${CADDY_VERSION}
COPY --from=route53 /usr/bin/caddy /usr/bin/caddy
