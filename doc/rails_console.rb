uid = "895685163"
token = "AAAFNKZCBGXpABAHQoMDIdLOABlzr4f8KHzUNXDTga0m9MfXEsVnM1gATNNsbcQpX7iFzrSIVC64ChO9ZAMDheowcGxyzRAPHrRNtU65AZDZD"
mfb = MongoFacebook.new(uid,token)
fb = mfb.facebook
db  = mfb.data.db

collection_name = 'get_connections__me_feed'
coll = db.collection(collection_name)

