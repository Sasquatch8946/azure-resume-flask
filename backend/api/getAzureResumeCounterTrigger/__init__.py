import logging

import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    import logging
import json
import os
import sys
import uuid

#from azure.core.exceptions import AzureError
from azure.cosmos import CosmosClient, PartitionKey
import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    ENDPOINT = os.environ["COSMOS_ENDPOINT"]
    KEY = os.environ["COSMOS_KEY"]
    database_name = 'CloudResume'
    container_name = 'Counter'

    client = CosmosClient(url=ENDPOINT, credential=KEY)

    database = client.get_database_client(database_name)

    container = database.get_container_client(container_name)

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

    out_counter = json.dumps(my_item)

    return out_counter
