import azure.functions as func 
import unittest 

from getAzureResumeCounterTrigger import main
from unittest import mock 

class TestgetAzureResumeCounterTrigger(unittest.TestCase):

    def test_getAzureResumeCounterTrigger(self):
        req = func.HttpRequest(
        method='GET',
        url='/api/getAzureResumeCounterTrigger',
        body=None
        )
        r = main(req) 
        assert isinstance(r, str)
