FROM metabase/metabase

RUN apk add --no-cache --upgrade ca-certificates && \
    AAA_CERTIFICATE_SERVICES=D7:A7:A0:FB:5D:7E:27:31:D7:71:E9:48:4E:BC:DE:F7:1D:5F:0C:3E:0A:29:48:78:2B:C8:3E:E0:EA:69:9E:F4 && \
    EMSIGN_ROOT_TLS_CA_G3=7D:D7:8D:5F:4F:13:45:9A:83:DF:F9:AB:BB:A6:2E:DB:AF:6F:2D:10:2B:F2:57:FD:71:2F:4D:9F:27:46:ED:8D && \
    for fp in $AAA_CERTIFICATE_SERVICES $EMSIGN_ROOT_TLS_CA_G3; do \
      keytool -list -v -cacerts -storepass changeit \
        | awk -v fp="$fp" '/^Alias name:/ { a = substr($0, 13) } $1 == "SHA256:" && $2 == fp { print a }' \
        | while read -r alias; do keytool -delete -cacerts -storepass changeit -alias "$alias"; done; \
      ! keytool -list -v -cacerts -storepass changeit | grep -q "SHA256: $fp" || exit 1; \
    done
