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

# install jobsvc-poller-operator assets
ARG VERSION
RUN --mount=type=secret,id=scmtok \
    curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/scmtok)" \
    https://scm.starbucks.com/api/v3/repos/retail-infrastructure-engineering/jobsvc-poller-operator/releases | \
    jq -r --arg release "$VERSION" --arg asset "jobsvc-poller-operator-$VERSION-amd64-linux.gz" \
    '.[] | select(.name==$release) | .assets.[] | select(.name==$asset) | .url' > asset_url.txt
RUN --mount=type=secret,id=scmtok \
    curl -L \
    -H "Accept: application/octet-stream" \
    -H "Authorization: Bearer $(cat /run/secrets/scmtok)" \
    "$(cat asset_url.txt)" > /root/jobsvc-poller-operator.gz && \
    gunzip /root/jobsvc-poller-operator.gz && \
    chmod +x /root/jobsvc-poller-operator

# construct final image with certs and operator bin
FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /root/jobsvc-poller-operator .
USER 9999:9999
CMD ["./jobsvc-poller-operator"]
