require 'json'
require 'rest-client'
require 'uri'

class PollVault

	def initialize endpoint=nil, api_key=nil, cache=true
		@cache = cache ? {} : nil
		@endpoint = endpoint || 'http://pollvault.org'
		@api_key = api_key
	end


	def get target, params={}
		return nil unless @api_key

		url = URI.join(@endpoint, 'api/', 'voter/', target).to_s
		query_hash = cache_get(url, params)

		params['hash'] = query_hash if query_hash && @cache
		params['api'] = @api_key

		begin
			data = JSON.parse(RestClient.get url, {:params => params}) rescue {}
		rescue Exception => e
			$stderr.puts "POLLVAULT ERROR #{e.message}"
			data = {'failed' => true}
		end

		data['no_data'] = query_hash == data['hash'] || data['failed']
		cache_set url, params, data['hash'] unless data['no_data']

		data
	end
	def post
	end

	# in-memory cache system of the PollVault hashes
	def cache_get url, params
		@cache ? @cache["#{url}#{params}".to_sym] : nil
	end
	def cache_set url, params, hash
		params.delete('hash')
		params.delete('api')
		@cache["#{url}#{params}".to_sym] = hash if @cache
	end

	def retrieve_by_state state
		get "state/#{state}"
	end
	def retrieve_by_address address
		get "search/", {"address" => address}
	end
	def retrieve_by_latlng latlng
		get "search/", {"latlng" => latlng}
	end
end

$pollvault = PollVault.new ENV['POLLVAULT_URL'], ENV['POLLVAULT_API']