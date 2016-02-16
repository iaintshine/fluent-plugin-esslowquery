#fluent-plugin-esslowquery

Fluent parser plugin for Elasticsearch slow query log file.

##Installation

```shell
$ td-agent-gem install fluent-plugin-esslowquery
```

##How to use

Edit `/etc/td-agent/td-agent.conf` file.

```conf
<source>
  type tail
  path /var/log/elasticsearch/elasticsearch-{cluster-name}_index_search_slowlog.log
  tag elasticsearch.{cluster-name}.search_slowlog_query
  pos_file /var/run/td-agent/elasticsearch-search-slow.pos
  format es_slow_query
</source>

<source>
  type tail
  path /var/log/elasticsearch/elasticsearch-{cluster-name}_index_indexing_slowlog.log
  tag elasticsearch.{cluster-name}.indexing_slowlog_query
  pos_file /var/run/td-agent/elasticsearch-indexing-slow.pos
  format es_slow_indexing
</source>
```

##Expected record format

### Slow Query
```json
{
    "extra_source": "{\"from\":0,\"size\":0}",
    "index": "comments",
    "node": "{cluster-name}-{node-id}",
    "search_type": "COUNT",
    "severity": "TRACE",
    "shard": 4,
    "source": "index.search.slowlog.query",
    "source_body": "{\"query\":{\"filtered\":{\"query\":{\"match_all\":{}},\"filter\":{\"term\":{\"tags\":\"elasticsearch\"}}}}}",
    "stats": "",
    "took": "282.7ms",
    "took_millis": 282,
    "total_shards": 1,
    "types": "document"
}
```
### Slow Indexing

```json
{
    "severity": "INFO ",
    "source": "index.indexing.slowlog.index",
    "node": "{cluster-name}-{node-id}",
    "index": "comments",
    "shard": 4,
    "took": "891.4ms",
    "took_millis": 891,
    "type": "document",
    "indexing_id": 120543866,
    "routing": 2012927,
    "source_body": "{}"
}
```