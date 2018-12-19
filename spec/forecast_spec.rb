require 'rspec'

require_relative '../app/forecast'
require_relative 'spec_helper.rb'

RSpec.describe 'next_three_days' do
  it 'returns the weather data' do
    VCR.use_cassette('5_day_weather_edinburgh') do
      expected = {
        1 => {
          daytime: { text: 'Light rain', weather_id: 12 },
          night: { text: 'Cloudy', weather_id: 7 }
        },
        2 => {
          daytime: { text: 'Cloudy', weather_id: 7 },
          night: { text: 'Cloudy', weather_id: 7 }
        },
        3 => {
          daytime: {
            text: 'Cloudy',
            weather_id: 7
          },
          night: {
            text: 'Cloudy', weather_id: 7
          }
        }
      }
      expect(Forecast.next_three_days).to eq(expected)
    end
  end
end
