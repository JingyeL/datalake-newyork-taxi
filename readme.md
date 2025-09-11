# NYC Yellow Taxi: Building a Scalable Lakehouse with PySpark, AWS Glue & Apache Iceberg
This project demonstrates how to build a scalable lakehouse architecture using PySpark, AWS Glue, and Apache Iceberg. We will ingest, process, and analyze New York City Yellow Taxi data, showcasing best practices for data engineering and analytics.

## Business Context
The NYC Taxi and Limousine Commission publishes trip data collected from yellow taxis. As a data engineer, you're asked to:

- Ingest historical taxi trip data
- Ingest new monthly trip data into a data lake
- Maintain a unified and query-efficient Iceberg table
- Support schema evolution as new fields (e.g. EV support, congestion zone fees) are introduced
- Enable auditable analytics via time travel
- Ensure efficient partitioning and metadata management for scalable querying

## Hands on Challenges
### pyspark, AWS Glue, Apache Iceberg)
1. Read historical data from source csv file via https.
2. Read new monthly data from source csv file via a peudo streaming source.
3. Write historical and new monthly data to a unified Iceberg table in S3 with appropriate partitioning.
4. Perform schema evolution to add new columns. `ulez_flag` and `congestion_surcharge`
5. register the Iceberg table in AWS Glue Catalog.

Key features:
- Schema evolution: gracefully handle newly added fields
- Partitioning: by pickup date (e.g., pickup_date=yyyy-mm-dd)
- Deduplication (optional): based on a natural key or hash
- Metadata strategy: track ingestion date/versioning

### Time Travel
Use Iceberg APIs to
  - Insert new data
  - Query data as of a specific version or timestamp
  - Rollback to an earlier version

### SQL or Athena Query
1. Total trips and average fare per day in January 2024
2. Top 10 pickup locations by month 2024
3. Average trip distance and duration by hour of day

### Extensions (Optional)
1. Add CDC simulation: update/cancel trip logic
2. Use Glue Bookmarking to avoid reprocessing
3. Integrate with Data Catalog crawlers for metadata freshness
4. Track schema changes in a side table (schema registry)

## Data Sources
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page


## Architecture Diagram - historical load
![Architecture Diagram](docs/nyc-taxi-lakehouse-architecture.png)