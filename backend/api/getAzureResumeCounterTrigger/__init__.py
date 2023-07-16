import logging

import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

import logging
import json
import os


#from azure.core.exceptions import AzureError
from azure.cosmos import CosmosClient, PartitionKey
import azure.functions as func

def getContainer():
    ENDPOINT = os.environ["COSMOS_ENDPOINT"]
    KEY = os.environ["COSMOS_KEY"]
    database_name = 'CloudResume'
    container_name = 'Counter'

    client = CosmosClient(url=ENDPOINT, credential=KEY)

    database = client.get_database_client(database_name)

    container = database.get_container_client(container_name)

    return container

def getCounter(container):

    my_item = container.read_item(item="1", partition_key="1")

    return my_item

def increaseCounter(my_item):

    count = int(my_item['count'])

    new_count = str(count + 1)

    return new_count

def updateCosmosDB(container, new_count):
    container.upsert_item({
        'id': '1',
        'count': f'{new_count}'
        }
    )

def outCounter(container):

    my_item = container.read_item(item="1", partition_key="1")

    out_counter = json.dumps(my_item)

    return out_counter

def main(req: func.HttpRequest, db_connect) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    #ENDPOINT = os.environ["COSMOS_ENDPOINT"]
    #KEY = os.environ["COSMOS_KEY"]
    #database_name = 'CloudResume'
    #container_name = 'Counter'

    #client = CosmosClient(url=ENDPOINT, credential=KEY)

    #database = client.get_database_client(database_name)

    #container = database.get_container_client(container_name)

    #my_item = container.read_item(item="1", partition_key="1")

    #container = getContainer()

    #my_item = getCounter(container=container)

    #count = int(my_item['count'])

    #new_count = str(count + 1)

    #new_count = increaseCounter(my_item=my_item)
    # update value
    #container.upsert_item({
    #    'id': '1',
    #    'count': f'{new_count}'
    #    }
    #)

    #updateCosmosDB(container=container, new_count=new_count)

    #out_counter = outCounter(container=container)
    db_info = db_connect

    return db_info
