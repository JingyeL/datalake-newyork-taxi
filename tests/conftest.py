"""
Test configuration and fixtures for NYC Yellow Taxi Data Lake
"""

import boto3
import pandas as pd
import pytest
from moto import mock_glue, mock_s3


@pytest.fixture
def sample_taxi_data():
    """Create sample taxi data for testing"""
    data = {
        "pickup_datetime": ["2024-01-01 10:00:00", "2024-01-01 11:00:00"],
        "dropoff_datetime": ["2024-01-01 10:30:00", "2024-01-01 11:20:00"],
        "pickup_longitude": [-73.9857, -73.9857],
        "pickup_latitude": [40.7484, 40.7484],
        "dropoff_longitude": [-73.9750, -73.9750],
        "dropoff_latitude": [40.7589, 40.7589],
        "passenger_count": [1, 2],
        "trip_distance": [2.5, 1.8],
        "fare_amount": [15.5, 12.0],
    }
    return pd.DataFrame(data)


@pytest.fixture
def s3_client():
    """Create mock S3 client"""
    with mock_s3():
        yield boto3.client("s3", region_name="us-east-1")


@pytest.fixture
def glue_client():
    """Create mock Glue client"""
    with mock_glue():
        yield boto3.client("glue", region_name="us-east-1")
