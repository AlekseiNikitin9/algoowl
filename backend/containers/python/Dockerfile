FROM python:3.12-alpine

# Create non-root user
RUN adduser -D -u 1000 sandbox

# Copy runner
COPY runner.py /opt/runner.py

# Make filesystem read-only except /tmp
RUN chmod 444 /opt/runner.py

USER sandbox
WORKDIR /tmp

ENTRYPOINT ["python3", "/opt/runner.py"]
