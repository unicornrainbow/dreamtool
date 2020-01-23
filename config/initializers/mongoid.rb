
# Monkey patch BSON to return string keys in json
# https://github.com/rails-api/active_model_serializers/issues/354
module BSON
  class ObjectId
    def as_json(*args)
      to_s
    end

  end
end

Mongoid.raise_not_found_error = false
