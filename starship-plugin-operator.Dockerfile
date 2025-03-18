FROM alpine:3.21.3 AS build

WORKDIR /root/

# install basic utils
RUN apk update
RUN apk upgrade
RUN apk --no-cache add curl
RUN apk --no-cache add zip
RUN curl -Lo jq-linux64 https://github.com/stedolan/jq/releases/download/jq-1.7.1/jq-linux64 && \
    mv jq-linux64 /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq

# install starship-plugin-operator assets
ARG VERSION
RUN --mount=type=secret,id=scmtok \
    curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/scmtok)" \
    https://scm.starbucks.com/api/v3/repos/retail-infrastructure-engineering/starship-plugin-operator/releases | \
    jq -r --arg release "$VERSION" --arg asset "starship-plugin-operator-$VERSION-amd64-linux.gz" \
    '.[] | select(.name==$release) | .assets.[] | select(.name==$asset) | .url' > asset_url.txt
RUN --mount=type=secret,id=scmtok \
    curl -L \
    -H "Accept: application/octet-stream" \
    -H "Authorization: Bearer $(cat /run/secrets/scmtok)" \
    "$(cat asset_url.txt)" > /root/starship-plugin-operator.gz && \
    gunzip /root/starship-plugin-operator.gz && \
    chmod +x /root/starship-plugin-operator

# construct final image with certs and operator bin
FROM scratch

LABEL org.opencontainers.image.source=https://github.com/core-infra-svcs/starship-job-operator
LABEL org.opencontainers.image.description="starship job operator horizontally scales and runs containers that can be remotely started via starship services"
LABEL org.opencontainers.image.licenses=MIT

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /root/starship-plugin-operator .
USER 9999:9999
CMD ["./starship-plugin-operator"]
