import sys
import hashlib

bytes = open(sys.argv[1], "rb").read()
print(hashlib.blake2b(bytes).hexdigest())
