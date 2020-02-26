# Compiler image
FROM didstopia/base:go-alpine-3.5 AS go-builder

# Copy the project 
COPY . /tmp/factocord/
WORKDIR /tmp/factocord/

# Install dependencies
RUN make deps

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/factocord



# Runtime image
FROM scratch

# Copy certificates
COPY --from=go-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Copy the built binary
COPY --from=go-builder /go/bin/factocord /go/bin/factocord

# Expose environment variables
ENV DiscordToken       "DiscordTokenHere"
ENV FactorioChannelID  "ChannelIDHere"
ENV LaunchParameters   "--start-server-load-latest --server-settings /path/to/file.json"
ENV Executable         "/path/to/file"
ENV AdminIDs           "AdminIDsHere,SeperateByComma"
ENV Prefix             "$"
ENV ModListLocation    "/path/to/mods/mod-list.json"
ENV GameName           "Factorio"

# Expose volumes
#VOLUME [ "/.db" ]

# Run the binary
ENTRYPOINT ["/go/bin/factocord"]
