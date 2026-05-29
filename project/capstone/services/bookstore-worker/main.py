"""BlueLeaf ingest worker. Demo only: pretends to fetch a book catalog
and print rows. Real implementation would read from a queue / Event Hub
and write to the database / Blob storage."""

import os
import time

def fetch_batch():
    return [
        {"id": 1, "title": "Site Reliability Engineering"},
        {"id": 2, "title": "Accelerate"},
    ]

def main():
    interval = int(os.environ.get("POLL_INTERVAL_SECONDS", "30"))
    while True:
        for book in fetch_batch():
            print(f"ingested: {book['id']} - {book['title']}", flush=True)
        time.sleep(interval)

if __name__ == "__main__":
    main()
