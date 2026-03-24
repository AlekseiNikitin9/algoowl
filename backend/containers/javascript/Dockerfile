FROM node:20-alpine

# Create non-root user (uid 1001 — node:alpine already has uid 1000)
RUN adduser -D -u 1001 sandbox

# Copy runner
COPY runner.js /opt/runner.js

# Make filesystem read-only except /tmp
RUN chmod 444 /opt/runner.js

USER sandbox
WORKDIR /tmp

ENTRYPOINT ["node", "/opt/runner.js"]
