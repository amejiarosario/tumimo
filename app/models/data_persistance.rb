class DataPersistance
  attr_accessor :db
  def initialize(database_name, port=27017, server='localhost')
    conn = Mongo::Connection.new(server,port)
    @db = conn.db database_name.to_s
  end

  # Checks if the data already exists, if not retrive the data.
  #
  #  * collection_name: name in the database
  #  * uid: unique identifier
  #  * cache_indicator: return a flag with the data to indicated if the data was cached or not.
  #  * ttl: time to live in relative time. e.g. 1.week = 604800, 1.day = 86400
  #  * block: code block
  #
  def cached(collection_name, uid, cache_indicator=false, ttl=nil,  &block)
    cached = true
    data = db.collection(collection_name).find_one(_id: uid)
    # puts "data::#{data}"
    # puts "expired::#{expired?(data,ttl)}"
    if expired?(data,ttl)
      data = block.call 
      cached = false
      data = insert_data(collection_name,uid,data)
    end
    # data = data['data']
    cache_indicator ? [cached, data] : data
  end

  def insert_data(collection_name, uid, data)
    hash = 
      {_id: uid}.merge(
      {metadata: metadata}).merge(
      {data: data})    
    id = db.collection(collection_name).insert(hash)
    hash
  end

  # Is expired if
  #   * data == nil
  #   * updated_at + ttl <= Time.now.to_i
  # if ttl is nil it wont check the updated_at
  def expired?(data, ttl)
    # puts "* expired?::data.nil?"
    return true if data.nil?
    # puts "** expired?::data[:metadata][:updated_at] => #{data[:metadata][:updated_at].inspect}"
    return true unless data && data[:metadata] && data[:metadata][:updated_at]
    updated_at = data[:metadata][:updated_at].to_i
    # puts "*** expired?::ttl.nil? | ttl=#{ttl}; updated_at = #{updated_at}"
    ttl.nil? ? false : (updated_at + ttl.to_i <= Time.now.to_i)
  end 

  # Provides information about versioning and data type
  #
  # data_type: [:versioned, :diff, :history, :feed]
  #   * feed: large amount of data that never changes, but always have a new chunk periodically. The old data 
  #   * versioned: store raw data that change over time but not is suitable to reduce by diff. (user descriptions/bio, displays, photos,...)
  #   * history: store raw data over time, can be reduce to diff_data. (friend_ids lists)
  #   * diff: it's the history_data processed with diff increments.
  def metadata
    {
      created_at: Time.now.to_i,
      updated_at: Time.now.to_i,
      version: '0.3',
      source: 'mongo_structure',
      data_type: 'versioned',
      next_cursor: ''
    }
  end
end