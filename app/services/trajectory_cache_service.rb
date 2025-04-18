class TrajectoryCacheService
  def initialize(cache_service)
    @cache = cache_service
  end

  # key = "ship:7b57bda6-3e4d-4700-8124-bb5f14a16ff5"
  def version(key)
    @cache.get(key)
  end

  # key = "ship:7b57bda6-3e4d-4700-8124-bb5f14a16ff5"
  # value = 1744960607
  def save_version(key, value)
    @cache.set(key, value)
  end

  # {"future:grid:1744967253:1:0"=>[{:ship_id=>"7b57bda6-3e4d-4700-8124-bb5f14a16fa7", :x=>550, :y=>0, :version=>"1744967252"}]
  # "future:grid:1744967254:1:0"=>[{:ship_id=>"7b57bda6-3e4d-4700-8124-bb5f14a16fa7", :x=>600, :y=>0, :version=>"1744967252"}],
  #  "future:grid:1744967255:1:0"=>[{:ship_id=>"7b57bda6-3e4d-4700-8124-bb5f14a16fa7", :x=>650, :y=>0, :version=>"1744967252"}]
  def set_trajectory(trajectory)
    @cache.batch_set_insert(trajectory)
  end

  # key = "future:grid:1744964812:1:0"
  def get_trajectory(key)
    @cache.smembers(key)
  end
end