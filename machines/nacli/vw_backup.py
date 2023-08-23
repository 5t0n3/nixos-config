import json
import os
from pathlib import Path
import sqlite3
import tarfile
from tempfile import TemporaryFile

from b2sdk.v2 import (
    B2Api,
    InMemoryAccountInfo,
    EncryptionSetting,
    EncryptionMode,
    EncryptionAlgorithm,
)
from cryptography.fernet import Fernet

db_backup_name = "db.sqlite3.bak"
enc_archive_name = "vw_backup.tar.xz.enc"
backup_files = [db_backup_name, "attachments", "rsa_key.pem", "rsa_key.pub.pem"]

# load configuration supplied as a systemd credential :)
cred_folder = Path(os.environ["CREDENTIALS_DIRECTORY"])
config_path = cred_folder / "config.json"
with open(config_path) as cfg:
    config = json.load(cfg)

f = Fernet(config["key"])

# dump vault database
con = sqlite3.connect("db.sqlite3")
backup = sqlite3.connect(db_backup_name)
con.backup(backup)
print("Backed up vault database")

con.close()
backup.close()

# create compressed tar archive of vault data
with TemporaryFile() as tmp:
    with tarfile.open(fileobj=tmp, mode="w:xz") as tar:
        for filename in backup_files:
            if Path(filename).exists():
                tar.add(filename)
                print(f"Added {filename} to archive")

    # encrypt archive & write to disk
    tmp.seek(0)

    # it's probably not super efficient to read the entire file into
    # memory but it's only a few megabytes for now so it's probably fine
    tar_data = tmp.read()

    enc_b64 = f.encrypt(tar_data)

# authorize to backblaze b2
info = InMemoryAccountInfo()
b2_api = B2Api(info)
b2_api.authorize_account(
    "production", config["application_key_id"], config["application_key"]
)

# upload encrypted backup to configured bucket
bucket = b2_api.get_bucket_by_id(config["bucket_id"])
bucket.upload_bytes(
    enc_b64,
    enc_archive_name,
    content_type="text/plain",
    encryption=EncryptionSetting(EncryptionMode.SSE_B2, EncryptionAlgorithm.AES256),
)
print("Successfully uploaded encrypted backup archive to B2!")

# delete remaining files
Path(db_backup_name).unlink()
