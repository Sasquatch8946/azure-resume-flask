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
        return func.HttpResponse("Document not found", status_code=404)

      updated_count = documents[0]

      # Here is where the counter gets updated.
      updated_count['count'] = updated_count['count'] + 1

      # Push output binding.
      documentsOut.set(updated_count)

      # Return HTTP response containing ID and Count fields from document.
      return func.HttpResponse(
        json.dumps(documents[0].to_dict()),
        mimetype="application/json"
      )


