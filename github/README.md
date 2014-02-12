## Installation

`$ bundle install`

##Example usage


#### List open pull requests
```
$ GITHUB_ACCESS_TOKEN=<your token here> bundle execute lib/list_pulls.rb

Pull request: Gsla nrt00 init
repo: AODN-ETL/GSLA_NRT00
created at: 2014-02-06 01:47:30 UTC
url: https://github.com/AODN-ETL/GSLA_NRT00/pull/2
description: Please needs review.

Pull request: fix geom display and add size column to _map . ready to deploy
repo: AODN-ETL/SOOP_BA
created at: 2014-01-29 05:05:19 UTC
url: https://github.com/AODN-ETL/SOOP_BA/pull/2
description: 
...
```

#### List open pull requests, short format, in chronological order

```
$ GITHUB_ACCESS_TOKEN=<your token here> bundle execute lib/list_pulls.rb --short | sort

2013-06-27 23:49:23 UTC https://github.com/aodn/imos-user-code-library/pull/2
2013-10-17 07:29:48 UTC https://github.com/aodn/imos-user-code-library/pull/5
2014-01-27 23:54:30 UTC https://github.com/aodn/aodn-portal/pull/880
2014-01-29 05:05:19 UTC https://github.com/AODN-ETL/SOOP_BA/pull/2
...
```