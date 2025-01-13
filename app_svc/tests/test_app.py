import sys
import os 

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app 
import pytest
import requests_mock

@pytest.fixture
def mock_api():
    with requests_mock.Mocker() as m:
        yield m

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

def test_about(client):
    """Test the about route."""
    response = client.get('/read_db')
    # print(response)
    assert response.status_code == 200



def test_non_existent_route(client):
    """Test for a non-existent route."""
    response = client.get('/non-existent')
    assert response.status_code == 404
