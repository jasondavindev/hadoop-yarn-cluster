## Glue - S3 protocol Troubleshooting

For tables in Glue with location/path prefixed with `s3://` is required to duplicate the table using `CREATE EXTERNAL TABLE ... LOCATION 's3a://....'`.
