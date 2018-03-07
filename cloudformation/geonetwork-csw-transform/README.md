### geonetwork-csw-transform 

tl;dr retrives csw documents, transforms them, then re-hosts the document in s3 

#### Cloudformation resources:
- s3 bucket (configured as public website)
- lambda
- lambda role and policy
- cloudwatch event
- cloudwatch->lambda permission 

#### Add a configuration
Add a new config object to the json in the CloudWatch event:

```
{
  ...
  "configs": [
    {
      "url": "<url of csw endpoint>",
      "output_key": "<name for output file>",
      "find": "<the text to find>",
      "replace": "<the text to replace it with>"
    },
    {
        //add new config
    }
  ]
}
```

#### Launch a stack
Just run up in CloudFormation; no params required.


