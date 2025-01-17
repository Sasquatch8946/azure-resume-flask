import sys
import os 

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app
import pytest
import json
import responses
import os

@pytest.fixture
def client():
    """A test client for the app."""
    with app.test_client() as client:
        yield client

def test_home(client):
    """Test the home route."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hi, I'm Sean Chapman" in response.data

@responses.activate
def test_read_db(client):
    """Test the read_db route."""
    FUNCTION_URL = os.getenv("FUNCTION_URL")
    mocked_response = {"id": "1", "count": 2}
    responses.add( 
        method=responses.GET,
        url=FUNCTION_URL, 
        json=mocked_response,
        status=200
    )

    response = client.get('/read_db')
    assert response.status_code == 200
    assert json.loads(response.get_data(as_text=True)) == mocked_response
    assert response.headers['Cache-Control'] == 'no-store'

@responses.activate
def test_read_db_too_many_requests(client):
    """Test the read_db route when the external API gets called to many times"""
    FUNCTION_URL = os.getenv("FUNCTION_URL")
    mocked_response = {"statusCode": 429, "message": "Rate limit is exceeded."}
    responses.add( 
        method=responses.GET,
        url=FUNCTION_URL, 
        json=mocked_response,
        status=429
    )

    response = client.get('/read_db')
    assert response.status_code == 429
    assert json.loads(response.get_data(as_text=True)) == mocked_response
    assert response.headers['Cache-Control'] == 'no-store'




def test_non_existent_route(client):
    """Test for a non-existent route."""
    response = client.get('/non-existent')
    assert response.status_code == 404
