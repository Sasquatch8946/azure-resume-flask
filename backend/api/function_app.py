import azure.functions as func
import logging
import json



app = func.FunctionApp()

@app.function_name(name="getCloudResumeCount")
@app.route(route="hello")
@app.cosmos_db_input(arg_name="documents", 
                     database_name="CloudResume",
                     container_name="Counter",
                     id="1",
                     partition_key="1",
                     connection="MyAccount_COSMOSDB")
@app.cosmos_db_output(arg_name="documentsOut", 
                      database_name="CloudResume",
                      container_name="Counter",
                      connection="MyAccount_COSMOSDB")
def getAndUpdateCount(req: func.HttpRequest, documents: func.DocumentList, documentsOut: func.Out[func.Document]) -> func.HttpResponse:
      if not documents:
        logging.warning("Documents item not found")
      else:
        logging.info("Found Documents item, Count=%s",
                     documents[0]['count'])

      count_int = documents[0]['count']

      # Here is where the counter gets updated.
      count_new = count_int + 1

      # Create dict to update DB item with.
      mydict = {"id": "1", "count": count_new}

      # Push output binding.
      documentsOut.set(func.Document.from_dict(mydict))

      # Return HTTP response containing ID and Count fields from document.
      # Test
      return func.HttpResponse(
        json.dumps(mydict),
        mimetype="application/json",
      )

    
