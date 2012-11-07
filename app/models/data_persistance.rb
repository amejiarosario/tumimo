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
  def fetch(collection_name, uid, options={}, &block)
    options[:cache_indicator] ||= false
    options[:ttl] ||= nil
    options[:data_type] ||= 'raw'

    data = options[:data_type] == 'raw' ? db.collection(collection_name).find_one(_id: uid) : nil
    cached = true
    if expired?(data,options[:ttl])
      data = block.call 
      cached = false
      data = insert_data(collection_name, uid, data, options)
    end
    options[:cache_indicator] ? [cached, data] : data
  end

  def insert_data(collection_name, uid, data, options={})
    hash = 
      {'_id' => uid}.merge(
      {'metadata' => metadata(options)}).merge(
      {'data' => process_data(uid,data,options)})    
    id = db.collection(collection_name).insert(hash)
    hash
  end

  def process_data(uid,data,options={})
    case options[:data_type]
    when 'raw'
      data
    when 'diff'
      additions = [6]
      removals = []
      {'raw' => data, '++' => additions, '--' => removals}
    else
      data
    end
  end

  # Indicates if data has expired
  #   * data: is a hash which should contain the field [:metadata][:updated_at]
  #   * ttl: is the time to live expressed in relative time. e.g. 1.week = 604800, 1.day = 86400
  #
  # Is expired if
  #   * data == nil
  #   * updated_at + ttl <= Time.now.to_i
  # if ttl is nil it wont check the updated_at
  #
  def expired?(data, ttl)
    return true if data.nil?
    return true unless data && data['metadata'] && data['metadata']['updated_at']
    updated_at = data['metadata']['updated_at'].to_i
    ttl.nil? ? false : (updated_at + ttl.to_i <= Time.now.to_i)
  end  

  # Provides information about versioning and data type
  #
  # data_type: [:raw, :versioned, :diff, :history, :feed]
  #   * feed: large amount of data that never changes, but always have a new chunk periodically. The old data 
  #   * versioned: store raw data that change over time but not is suitable to reduce by diff. (user descriptions/bio, displays, photos,...)
  #   * history: store raw data over time, can be reduce to diff_data. (friend_ids lists)
  #   * diff: it's the history_data processed with diff increments.
  #   * raw: regular data
  #
  def metadata(options={})
    options[:data_type] ||= 'raw'
    {
      'created_at' => Time.now.to_i,
      'updated_at' => Time.now.to_i,
      'version' => '0.4',
      'source' => 'mongo_structure',
      'data_type' => options[:data_type],
      'next_cursor' => ''
    }
  end
end