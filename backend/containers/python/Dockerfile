FROM python:3.12-alpine

# Create non-root user
RUN adduser -D -u 1000 sandbox

# Copy both scripts
COPY execute.py /opt/execute.py
COPY runner.py  /opt/runner.py

RUN chmod 444 /opt/execute.py /opt/runner.py

USER sandbox
WORKDIR /tmp

EXPOSE 8001

ENTRYPOINT ["python3", "/opt/runner.py"]
