module Fluent
  class TextParser
    class ElasticsearchSlowIndexingLogParser < Parser
      REGEXP = /^\[(?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3})\]\[(?<severity>[a-zA-Z\s]+)\]\[(?<source>\S+)\] \[(?<node>\S+)\] \[(?<index>\w+)\]\[(?<shard>\d+)\] took\[(?<took>.+)\], took_millis\[(?<took_millis>\d+)\], type\[(?<type>.+)\], id\[(?<indexing_id>.*)\], routing\[(?<routing>.*)\], source\[(?<source_body>.*)\]/
      TIME_FORMAT = "%Y-%m-%d %H:%M:%S,%N"

      Plugin.register_parser("es_slow_indexing", self)

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
        indexing_id= m['indexing_id'].to_i
        routing = m['routing'].to_i

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
          'type' => m['type'],
          'indexing_id' => indexing_id,
          'routing' => routing,
          'source_body' => m['source_body']
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
end
