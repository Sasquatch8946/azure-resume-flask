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
                      connection="MyAccount_COSMOSDB",
                      create_if_not_exists=True,
                      partition_key="1")
def getAndUpdateCount(req: func.HttpRequest, documents: func.DocumentList, documentsOut: func.Out[func.Document]) -> func.HttpResponse:
      if not documents:
        logging.info("could not find documents, need to initialize docs")
        doc_dict = {'id': "1", 'count': 1}
        documentsOut.set(func.Document.from_dict(doc_dict))
        return func.HttpResponse(
        json.dumps(doc_dict),
        mimetype="application/json"
      )

      # Store retrieved doc in a variable.
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


