# Retrieves all users/groups info (id/username) from json output

import json
import sys

data = json.loads(sys.argv[1])
# print(data)
collection = ""
for values in data:
    collection += str(values[sys.argv[2]])+":"+values[sys.argv[3]]+";"
print(collection)
