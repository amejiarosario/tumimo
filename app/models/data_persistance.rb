class DataPersistance
  attr_accessor :db
  def initialize(database_name, port=27017, server='localhost')
    conn = Mongo::Connection.new(server,port)
    @db = conn.db database_name.to_s
  end

  # Checks if the data already exists, if not retrive the data.
  def cached(collection_name, uid, cached_flag=false, &block)
    cached = true
    unless data = db.collection(collection_name).find_one(_id: uid)
      data = block.call
      cached = false
      insert_data(collection_name,uid,data)
    end
    data = data['data'] || data
    cached_flag ? [cached, data] : data
  end

  def insert_data(collection_name, uid, data)
    db.collection(collection_name).insert(
      {_id: uid}.merge(
      metadata.merge(
      {data: data}))
    )
  end

  private
    
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