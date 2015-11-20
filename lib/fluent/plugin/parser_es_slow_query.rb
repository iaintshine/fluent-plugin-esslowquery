module Fluent
  class ElasticsearchSlowQueryLogParser < Parser
    REGEXP = /^\[(?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3})\]\[(?<severity>[a-zA-Z]+\s*)\]\[(?<source>\S+)\] \[(?<node>\S+)\] \[(?<index>\w+)\]\[(?<shard>\d+)\] took\[(?<took>.+)\], took_millis\[(?<took_millis>\d+)\], types\[(?<types>.*)\], stats\[(?<stats>.*)\], search_type\[(?<search_type>.*)\], total_shards\[(?<total_shards>\d+)\], source\[(?<source_body>.*)\], extra_source\[(?<extra_source>.*)\]/
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S,%N"

    Plugin.register_parser("es_slow_query", self)

    def initialize
      super
      @time_parser = TextParser::TimeParser.new(TIME_FORMAT)
      @mutex = Mutex.new
    end

    def patterns
      {'format' => REGEXP, 'time_format' => TIME_FORMAT}
    end

    def parse(text)
      m = REGEXP.match(text)
      unless m
        if block_given?
          yield nil, nil
          return
        else
          return nil, nil
        end
      end

      shard = m['shard'].to_i
      took_millis = m['took_millis'].to_i
      total_shards = m['total_shards'].to_i

      time = m['time']
      time = @mutex.synchronize { @time_parser.parse(time) }

      record = {
        'severity' => m['severity'],
        'source' => m['source'],
        'node' => m['node'],
        'index' => m['index'],
        'shard' => shard,
        'took' => m['took'],
        'took_millis' => took_millis,
        'types' => m['types'],
        'stats' => m['stats'],
        'search_type' => m['search_type'],
        'total_shards' => total_shards,
        'source_body' => m['source_body'],
        'extra_source' => m['extra_source']
      }
      record["time"] = m['time'] if @keep_time_key

      if block_given?
        yield time, record
      else
        return time, record
      end
    end
  end
end
