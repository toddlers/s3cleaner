s3cleaner
=========

## cleaning s3 with fog

## SYNOPSIS
```
λ: ruby s3cleaner.rb --help
Usage: s3cleaner.rb [options]

    -d, --delete                     Actually do a delete. If not specified , just list the keys found that match
    -c, --config FILE                Read options from file
    -h, --help                       Show this message
λ:
```

## Example config

```
# AWS Credentials
AWS_ACCESS_KEY_ID: '<AWS_ACCESS_KEY_ID'
AWS_SECRET_ACCESS_KEY: '<AWS_SECRET_ACCESS_KEY>'

#Buckets for with expiration period
BUCKETS:
  BUCKET1:
    AGE: '5d'
    REGEX: ''
  BUCKET2:
    AGE: '30d'
    REGEX: ''

```

- Two types of actions DELETE and LIST
  - LIST will only list the files
  - DELETE will do the actual delete
  - Default option is list
   
- Regex for files
  - You can leave that empty, if you dont want to search for pattern based file
  - If you specify the regex it will give only files which matches the regex


  ```Shell
λ: ruby s3cleaner.rb --config ebs_config.yaml  --delete
==Deleting 1000 in NewsProcessingDocumentsXML ==
==Deleting 0 in test-execharvestfromnews ==

  ```
  
  ```Shell
λ: ruby s3cleaner.rb --config ebs_config.yaml
==Below are the list of objects present in boo==

 == Total Number of File ==  1000
324699529692.xml
....
325010070352.xml
==Below are the list of objects present in foo==

 == Total Number of File ==  0
 
  ```


