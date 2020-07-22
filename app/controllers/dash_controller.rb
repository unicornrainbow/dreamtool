
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
    }, { "$sort": {"_id.year": 1, "_id.month": 1 } }]

    #User.all.group_by([:year, :month] => "created_at")

    @new_users = User.collection.aggregate(stages)

    @new_users = JSON.parse(@new_users.to_json)

    # @new_users[4] = {"_id"=>{"year"=>2020, "month"=>6}, "value"=>0}


    w = {}

    (2017..Date.current.year).each do |year|
      w[year] = {}
      (1..12).each do |month|
        w[year][month] = 0
      end
    end

    @new_users.each do |m|
      year = m["_id"]["year"]
      month = m["_id"]["month"]
      if w[year]
        w[year][month] = m["value"]
      end
    end

    @new_users = []
    (2017..Date.current.year).each do |year|
      if year == Date.current.year
        (1..Date.current.month).each do |month|
            @new_users <<  {"_id"=>{"year"=>year, "month"=>month},
              "value"=> w[year][month]}
          end
      else
        (1..12).each do |month|
          @new_users <<  {"_id"=>{"year"=>year, "month"=>month},
            "value"=> w[year][month]}
        end
      end


    end


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
