"""
NYC Yellow Taxi Data Validator Lambda Function
Validates incoming data quality and schema compliance
"""

import json
import logging
import os
from typing import Any, Dict, List, Optional

import boto3
import pandas as pd
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize AWS clients
s3_client = boto3.client("s3")
glue_client = boto3.client("glue")


class DataValidator:
    """Data validation class for NYC taxi data"""

    def __init__(self, bucket_name: str, glue_database: str):
        self.bucket_name = bucket_name
        self.glue_database = glue_database

    def validate_schema(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Validate DataFrame schema against expected taxi data schema"""
        required_columns = [
            "pickup_datetime",
            "dropoff_datetime",
            "pickup_longitude",
            "pickup_latitude",
            "dropoff_longitude",
            "dropoff_latitude",
            "passenger_count",
            "trip_distance",
            "fare_amount",
        ]

        validation_results = {"is_valid": True, "errors": [], "warnings": []}

        # Check required columns
        missing_columns = set(required_columns) - set(df.columns)
        if missing_columns:
            validation_results["is_valid"] = False
            validation_results["errors"].append(
                f"Missing required columns: {missing_columns}"
            )

        # Check data types and ranges
        if "passenger_count" in df.columns:
            invalid_passenger_count = df[
                (df["passenger_count"] < 1) | (df["passenger_count"] > 6)
            ]
            if len(invalid_passenger_count) > 0:
                validation_results["warnings"].append(
                    f"Invalid passenger count found: {len(invalid_passenger_count)} rows"
                )

        if "fare_amount" in df.columns:
            negative_fares = df[df["fare_amount"] < 0]
            if len(negative_fares) > 0:
                validation_results["warnings"].append(
                    f"Negative fare amounts found: {len(negative_fares)} rows"
                )

        return validation_results

    def validate_file(self, s3_key: str) -> Dict[str, Any]:
        """Validate a single file from S3"""
        try:
            # Download file from S3
            response = s3_client.get_object(Bucket=self.bucket_name, Key=s3_key)

            # Determine file type and read accordingly
            if s3_key.endswith(".parquet"):
                df = pd.read_parquet(response["Body"])
            elif s3_key.endswith(".csv"):
                df = pd.read_csv(response["Body"])
            else:
                return {
                    "is_valid": False,
                    "errors": [f"Unsupported file type: {s3_key}"],
                }

            # Validate schema
            validation_results = self.validate_schema(df)
            validation_results["file_key"] = s3_key
            validation_results["row_count"] = len(df)
            validation_results["column_count"] = len(df.columns)

            return validation_results

        except Exception as e:
            logger.error(f"Error validating file {s3_key}: {str(e)}")
            return {
                "is_valid": False,
                "errors": [f"Error processing file: {str(e)}"],
                "file_key": s3_key,
            }


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda handler for data validation

    Expected event format:
    {
        "s3_bucket": "bucket-name",
        "s3_keys": ["path/to/file1.parquet", "path/to/file2.csv"],
        "glue_database": "database-name"
    }
    """
    try:
        # Extract parameters from event
        bucket_name = event.get("s3_bucket", os.environ.get("DATA_LAKE_BUCKET"))
        s3_keys = event.get("s3_keys", [])
        glue_database = event.get("glue_database", os.environ.get("GLUE_DATABASE"))

        if not bucket_name:
            raise ValueError("S3 bucket name not provided")

        if not s3_keys:
            raise ValueError("No S3 keys provided for validation")

        # Initialize validator
        validator = DataValidator(bucket_name, glue_database)

        # Validate all files
        validation_results = []
        for s3_key in s3_keys:
            logger.info(f"Validating file: {s3_key}")
            result = validator.validate_file(s3_key)
            validation_results.append(result)

        # Summarize results
        total_files = len(validation_results)
        valid_files = sum(1 for r in validation_results if r["is_valid"])

        summary = {
            "total_files": total_files,
            "valid_files": valid_files,
            "invalid_files": total_files - valid_files,
            "validation_results": validation_results,
        }

        logger.info(f"Validation complete: {valid_files}/{total_files} files valid")

        return {"statusCode": 200, "body": json.dumps(summary), "summary": summary}

    except Exception as e:
        logger.error(f"Lambda execution error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e), "message": "Data validation failed"}),
        }


if __name__ == "__main__":
    # For local testing
    test_event = {
        "s3_bucket": "test-bucket",
        "s3_keys": ["test-data.csv"],
        "glue_database": "test-database",
    }
    result = lambda_handler(test_event, None)
    print(json.dumps(result, indent=2))
