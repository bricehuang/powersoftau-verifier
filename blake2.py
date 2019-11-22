import sys
import hashlib

bytes = open(sys.argv[0], "rb").read()
print(hashlib.blake2b(bytes).hexdigest())
