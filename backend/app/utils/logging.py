"""Centralised logging configuration for the AlgoOwl API."""

import logging
import sys


def setup_logging() -> None:
    fmt = logging.Formatter(
        fmt="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
        datefmt="%H:%M:%S",
    )
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(fmt)

    root = logging.getLogger()
    root.setLevel(logging.INFO)
    # Remove any existing handlers added by uvicorn/other libs
    root.handlers = [handler]

    # Silence noisy SQLAlchemy query logs
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
