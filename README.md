s3cleaner
=========

## cleaning s3 with fog

  ```Shell
λ: ruby s3cleaner.rb --help
Usage: s3cleaner.rb [options]

    -k, --key AWS_ACCESS_KEY         AWS ACCESS KEY ID
    -s, --secret AWS_SECRET_KEY      A SECRET ACCESS KEY
    -a, --maxage MAX_AGE             MAX_AGE In seconds
    -r, --regex REGEX                Only consider keys matching this REGEX
    -b, --bucket BUCKET              Search for keys in a specific bcuket
    -d, --delete                     Actually do a delete. If not specified , just list the keys found that match
    -h, --help                       Show this message
  ```

  ```Shell
λ: ruby s3cleaner.rb -k AWS_ACCESS_KEY  -s AWS_SECRET_KEY -a "1d" -b fog-demo-1396507025 -r test
The fog-demo-1396507025 is empty !!
  ```
  
  ```Shell
λ: ruby s3cleaner.rb -k AWS_ACCESS_KEY -s AWS_SECRET_KEY -a "1d" -b fog-demo-1396507000  -r Clustering
==Below is the list of files present in fog-demo-1396507000==
Clustering.jar
ClusteringNew.jar
  ```


