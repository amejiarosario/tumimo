class MongoStructure
  def initialize(database_name, port=27017, server='localhost')
    conn = Mongo::Connection.new(server,port)
    @db = conn.db database_name.to_s
  end

  def insert_data(collection_name, data)
    @db[collection_name].insert(metadata.merge({data: data}))
  end

  private
    
    # This method provides information about versioning and data type
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