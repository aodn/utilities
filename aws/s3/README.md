# S3 bucket static website
This folder contains html that render the S3 bucket static page, aka s3 AWS S3 Explorer. The s3 bucket
is configurate to host static page.

![s3](Screenshot%20from%202023-02-20%2012-10-43.png)

* https://data-test.aodn.org.au
* https://data.aodn.org.au
* https://content.aodn.org.au
* etc

You can find the full list in the aodn.js

> You can find the aws-s3-explorer in the github but that version changed too much that it do
> not work with the existing html that sore here. Major issue is that user will give link to 
> external user where the link of format xxx?prefix=yyy. This not longer works if you update the 
> html that store in github.
> 
> More details can be found here -> https://github.com/aodn/backlog/issues/650