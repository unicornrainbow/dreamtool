
class DashController < ApplicationController

  skip_before_action :track_hit, only: 'index'
  def index
    # group by created_at in Mongo
    # see: https://stackoverflow.com/a/34677100
    stages =  [{
      "$group": {
        "_id": {
          "year": { "$year": "$created_at" },
          "month": { "$month": "$created_at" }
        },
        "value": { "$sum": 1 }
      }
    }]

    #User.all.group_by([:year, :month] => "created_at")

    @new_users = User.collection.aggregate(stages)

    # @hits = $redis.get("Hits: #{Today.date}") || 0
    # @hits = Hit.get("Hits: #{Today.date}") || 0
    todays_date = Today.date
    @hits = Hit.where(date: todays_date)
    @signups = User.where(signup_date: todays_date)

    # ("Hits: #{Today.date}") || 0
    @visits = @hits.distinct(:ip)

    @total_users = User.count

    render layout: false
  end
end
