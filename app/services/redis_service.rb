class RedisService
  DEFAULT_TLL = 70

  def initialize
    @redis = Redis.new
  end

  def set(key, value, ex = DEFAULT_TLL)
    @redis.set(key, value, ex: ex)
  end

  def get(key)
    @redis.get(key)
  end

  def batch_set_insert(batch_data, ex = DEFAULT_TLL)
    @redis.pipelined do
      batch_data.each do |key, values|
        json_values = values.map { |value| value.to_json }
        @redis.sadd(key, *json_values)
        @redis.expire(key, ex)
      end
    end
  end

  def smembers(key)
    @redis.smembers(key)
  end
end