import json
import os
import sys
import uuid

from azure.core.exceptions import AzureError
from azure.cosmos import CosmosClient, PartitionKey

ENDPOINT = os.environ["COSMOS_ENDPOINT"]
KEY = os.environ["COSMOS_KEY"]
database_name = 'CloudResume'
container_name = 'Counter'

client = CosmosClient(url=ENDPOINT, credential=KEY)

#db_list = client.list_databases()

#for i in db_list:
#    print(i)

database = client.get_database_client(database_name)
container = database.get_container_client(container_name)

#items = container.read_all_items()

#for i in items:
#    print(i)

# TODO: refine this so it gets dict key containing current count
# store count in variable so it can be used in the upsert below

my_item = container.read_item(item="1", partition_key="1")

count = int(my_item['count'])

new_count = str(count + 1)
# update value
container.upsert_item({
    'id': '1',
    'count': f'{new_count}'
    }
)

my_item = container.read_item(item="1", partition_key="1")

new_count_from_db = my_item['count']

print(f'The count is now {new_count_from_db}.')
