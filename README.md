s3cleaner
=========

## cleaning s3 with fog

## SYNOPSIS
ebs_snapshot.rb -c config.yaml --dry

```
$: ruby s3cleaner.rb --help
Usage: s3cleaner.rb [options]

    -k, --key AWS_ACCESS_KEY         AWS ACCESS KEY ID
    -s, --secret AWS_SECRET_KEY      A SECRET ACCESS KEY
    -a, --maxage MAX_AGE             MAX_AGE in days
    -r, --regex REGEX                Only consider keys matching this REGEX
    -b, --bucket BUCKET              Search for keys in a specific bcuket
    -d, --delete                     Actually do a delete. If not specified , just list the keys found that match
    -c, --config FILE                Read options from file
    -h, --help                       Show this message
```

## Example config

```
# AWS credentials
aws_access_key_id: '<AWS_ACCESS_KEY_ID>'
aws_secret_key: '<AWS_SECRET_KEY>'

# specify the bucket definition
AGE: '15d'
BUCKET: '<BUCKET_NAME>'
REGEX: '<REGEX FOR THE FILES>'
ACTION: 'LIST'

```
- Two types of actions DELETE and LIST
  - LIST will only list the files
  - DELETE will do the actual delete


  ```Shell
λ: ruby s3cleaner.rb -k AWS_ACCESS_KEY  -s AWS_SECRET_KEY -a "1d" -b fog-demo-1396507025 -r test
The fog-demo-1396507025 is empty !!
  ```
  
  ```Shell
λ: ruby s3cleaner.rb --config config.yaml
==Below is the list of files present in FOO==

 == Total Number of File ==  132
316374825001.xml
316374993329.xml
  ```
  
  ```Shell
λ: ruby s3cleaner.rb -k AWS_ACCESS_KEY -s AWS_SECRET_KEY -a "1d" -b fog-demo-1396507000  -r Clustering
==Below is the list of files present in fog-demo-1396507000==
Clustering.jar
ClusteringNew.jar
  ```


