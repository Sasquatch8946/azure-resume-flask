import unittest 
from unittest import mock 
import azure.functions as func 
import json
from function_app import getAndUpdateCount

class TestgetAndUpdateCount(unittest.TestCase):

    def test_function_app(self):
        request = func.HttpRequest(
            method='GET',
            url='/api/Hello',
            body=None
        )
       
        # Need to create a func.DocumentList instance in order to mimic an actual DB item list.

        input_doclist = func.DocumentList(initlist=[{"id": "1", "count": 2}])

        # We don't actually want to write to the DB so we create a Mock object.

        output_doc = mock.Mock()

        # Call function under test.

        func_call = getAndUpdateCount.build().get_user_function()
        response = func_call(request, input_doclist, output_doc)

        # Assert that certain conditions are true.

        # HTTP response is OK
        assert response.status_code == 200

        # When given a count of 2, the function return 3, in other words +1.
        assert json.loads(response.get_body().decode())['count'] == 3

        # The function is calling the 'set' method on the output binding.

        assert output_doc.set.called




