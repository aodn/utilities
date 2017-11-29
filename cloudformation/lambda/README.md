## Purpose
The templates and code for deploying lambda functions. 
Each folder should be given the same name as the template that it holds (so it's usable by our jenkins job) .

## Lambda Code
Small code can be kept inline in the template's lambda definition. 
Larger code should be given it's own file (or files). The "code" attribute of the Lambda definition in the template should simply point to the local folder, "." so that we can then use the "package" commmand to deploy code changes.

## Packaging and Deploying
First run the aws cloudformation "package" cli command. This will upload the lambda code to s3 and create a new yaml which points to that code.
Example package command:

```aws cloudformation package --template-file .\auto_off_beanstalk.yaml --s3-bucket imos-binary-dev --s3-prefix lambda --output-template-file temp.yaml```
The s3 bucket must be in the same region you're deploying to.

Now run the deploy command on the temporary template file created by the the "package" command. The original template files cannot be deployed directly since they generally contain references to local lambda code.

```aws cloudformation deploy --template-file .\temp.yaml --stack-name my-example-stack --capabilities CAPABILITY_IAM```
