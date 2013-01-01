class DataPersistance
  attr_accessor :db
  READY = 'ready'
  PROCESSING = 'processing'
  
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
    options[:collection_name] = collection_name
    options[:uid] = uid
    options[:find_and_return] ||= false 

    data = find(collection_name,uid) 
    return data if options[:find_and_return] || block.nil?

    data = options[:data_type] == 'raw' ? data : nil
    cached = true
    if expired?(data,options[:ttl])
      data = block.call
      cached = false
      case options[:data_type]
      when 'feed'
        feed = data
        # check where was let of
        unless cached = db.collection(collection_name).find_one(uid: uid)
          # new data
          data = insert_data(collection_name,uid,feed,options)

          # get all feeds recursively (might take a couple of minutes)
          while feed.respond_to?(:next_page) && feed = feed.next_page
            feed.each do |one_entry|
              db.collection(collection_name).update({uid: uid}, {"$push" => {"data.raw" => one_entry }})
            end
            options[:next_page] = (feed && feed.paging && feed.paging.has_key?('next')) ? feed.paging['next'] : nil
            print '.'
          end 
          db.collection(collection_name).update({uid: uid}, {"$set" => {"metadata.status" => "ready" }}) 
          data = db.collection(collection_name).find_one(uid: uid)           
        else
          # there is data
          data = cached
        end
      else
        data = insert_data(collection_name, uid, data, options)
      end # case options[:data_type]    
    end # expired?

    options[:cache_indicator] ? [cached, data] : data
  end

  def find(collection_name, uid)
    db.collection(collection_name).find_one(uid: uid)
  end

  def insert_data(collection_name, uid, data, options={})
    hash = 
      {'uid' => uid}.merge(
      {'data' => process_data(uid,data,options)}).merge(
      {'metadata' => metadata(options)})    
    id = db.collection(collection_name).insert(hash)
    hash
  end

  def process_data(uid, data, options={})
    options[:status] = READY
    case options[:data_type]
    when 'raw'
      {'raw' => data }
    when 'feed'
      options[:status] = PROCESSING
      {'raw' => data, 'next_page' => options[:next_page]}
    when 'diff'
      last = db.collection(options[:collection_name]).find(uid: options[:uid].to_i).sort('_id' => :desc).limit(1).to_a[0]
      additions = removals = []
      unless last.nil?
        ldata = last['data']['raw']
        #puts "**** #{ldata}"
        additions = data - ldata
        removals = ldata - data
      end
      {'raw' => data, '++' => additions, '--' => removals}
    else
      {'raw' => data }
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
  # status: [:ready, :processing, :expired]
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
      'version' => '0.6',
      'source' => 'mongo_structure',
      'data_type' => options[:data_type],
      'status' => options[:status] || 'processing',
      'next_cursor' => ''
    }
  end
end