import json
from tempfile import TemporaryFile

from b2sdk.v2 import (
    B2Api,
    InMemoryAccountInfo,
    EncryptionSetting,
    EncryptionMode,
    EncryptionAlgorithm,
)
from cryptography.fernet import Fernet

with open("config.json") as cfg:
    config = json.load(cfg)

f = Fernet(config["key"])

# authorize to B2
info = InMemoryAccountInfo()
b2_api = B2Api(info)
b2_api.authorize_account(
    "production", config["application_key_id"], config["application_key"]
)

# download encrypted backup archive
bucket = b2_api.get_bucket_by_id(config["bucket_id"])
downloaded = bucket.download_file_by_name(
    "vw_backup.tar.xz.enc",
    encryption=EncryptionSetting(EncryptionMode.SSE_B2, EncryptionAlgorithm.AES256),
)

# save encrypted archive to temporary file for decryption
with TemporaryFile() as tmp:
    downloaded.save(tmp)

    # not sure if this seek is actually necessary but I figure
    # save() above might change the position in the file
    tmp.seek(0)

    # decrypt the archive :)
    archive_data = f.decrypt(tmp.read())

# write decrypted archive data to disk
with open("vw_backup.tar.xz", "wb") as f:
    f.write(dec)
