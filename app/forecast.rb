require 'net/http'
require 'json'
require 'pry-byebug'
require 'dotenv/load'

# Uses the met office api to return data for upcoming days
class Forecast
  def self.next_three_days
    uri = URI(five_day_forecast_url)
    response = Net::HTTP.get(uri)

    data_per_day(JSON.parse(response))
      .each.with_index
      .each_with_object({}) do |(item, index), output|
        output[index + 1] = build_item(item.first, item.last)
      end
  end

  def self.build_item(day_weather_id, night_weather_id)
    {
      daytime: {
        text: mapping[day_weather_id],
        weather_id: day_weather_id
      },
      night: {
        text: mapping[night_weather_id],
        weather_id: night_weather_id
      }
    }
  end

  def self.five_day_forecast_url
    api_key = ENV['API_KEY'].freeze
    root_url = 'http://datapoint.metoffice.gov.uk/public/data/val/wxfcs/all'
    url_format = 'json'
    location_id = 3166
    params = "res=daily&key=#{api_key}"
    "#{root_url}/#{url_format}/#{location_id}?#{params}"
  end

  def self.data_per_day(parsed_response)
    parsed_response['SiteRep']['DV']['Location']['Period']
      .drop(1)
      .take(3)
      .map { |i| i['Rep'] }
      .map { |i| i.map { |k| k['W'].to_i } }
  end

  def self.mapping # rubocop:disable Metrics/MethodLength
    {
      -1 => 'Not available',
      0 => 'Clear night',
      1 => 'Sunny day',
      2 => 'Partly cloudy (night)',
      3 => 'Partly cloudy (day)',
      4 => 'Not used',
      5 => 'Mist',
      6 => 'Fog',
      7 => 'Cloudy',
      8 => 'Overcast',
      9 => 'Light rain shower (night)',
      10 => 'Light rain shower (day)',
      11 => 'Drizzle',
      12 => 'Light rain',
      13 => 'Heavy rain shower (night)',
      14 => 'Heavy rain shower (day)',
      15 => 'Heavy rain',
      16 => 'Sleet shower (night)',
      17 => 'Sleet shower (day)',
      18 => 'Sleet',
      19 => 'Hail shower (night)',
      20 => 'Hail shower (day)',
      21 => 'Hail',
      22 => 'Light snow shower (night)',
      23 => 'Light snow shower (day)',
      24 => 'Light snow',
      25 => 'Heavy snow shower (night)',
      26 => 'Heavy snow shower (day)',
      27 => 'Heavy snow',
      28 => 'Thunder shower (night)',
      29 => 'Thunder shower (day)',
      30 => 'Thunder'
    }
  end
end
