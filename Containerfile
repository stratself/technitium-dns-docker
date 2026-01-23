FROM --platform=$BUILDPLATFORM docker.io/alpine:latest as build

ARG TARGETOS TARGETARCH
ARG DNS_SERVER_VERSION=v14.3.0

WORKDIR /build

# Install build packages
RUN apk -U add --no-cache libmsquic dotnet9-sdk git curl

RUN --mount=type=bind,source=technitium.patch,target=/build/technitium.patch <<HEREDOC
    
    if [ $TARGETARCH == 'amd64' ]; then 
        export DOTNETARCH="x64"
    else 
        export DOTNETARCH=${TARGETARCH}
    fi

    # Clone the repositories
    git clone --branch dns-server-${DNS_SERVER_VERSION} --depth 1 https://github.com/TechnitiumSoftware/TechnitiumLibrary.git TechnitiumLibrary
    git clone --branch=${DNS_SERVER_VERSION} --depth 1 https://github.com/TechnitiumSoftware/DnsServer.git DnsServer

    # Build TechnitiumLibraries
    dotnet build \
        TechnitiumLibrary/TechnitiumLibrary.ByteTree/TechnitiumLibrary.ByteTree.csproj \
        -c Release -r linux-musl-${DOTNETARCH} -o ./TechnitiumLibrary/bin
    dotnet build \
        TechnitiumLibrary/TechnitiumLibrary.Net/TechnitiumLibrary.Net.csproj \
        -c Release -r linux-musl-${DOTNETARCH} -o ./TechnitiumLibrary/bin
    dotnet build \
        TechnitiumLibrary/TechnitiumLibrary.Security.OTP/TechnitiumLibrary.Security.OTP.csproj \
        -c Release -r linux-musl-${DOTNETARCH} -o ./TechnitiumLibrary/bin

    # Compile DnsServer with applied patch
    git apply -v technitium.patch --directory DnsServer/
    dotnet publish \
        DnsServer/DnsServerApp/DnsServerApp.csproj \
        -c Release -r linux-musl-${DOTNETARCH} -o ./publish --self-contained

HEREDOC

FROM docker.io/alpine:latest

# Add runtime packages
RUN apk -U add --no-cache mimalloc icu-libs libmsquic doggo

ENV LD_PRELOAD="/usr/lib/libmimalloc.so"

WORKDIR /opt/technitium/dns

COPY --link --from=build /build/publish /opt/technitium/dns

ENTRYPOINT ["/opt/technitium/dns/DnsServerApp"]
CMD ["/etc/dns"]

LABEL org.opencontainers.image.title="Technitium DNS Server (stratself's fork)"
LABEL org.opencontainers.image.source="https://github.com/stratself/technitium-dns-docker"