class Google

  def self.extractContent(content)
    shell = {}
    keys = content.scan(/\w+(?=: )(?!::)/).flatten
    keys.length.times do |i|
      key = keys[i]
      start_chop = content.index(key+': ')+key.length+2
      finish_chop = keys[i+1].nil? ? content.length : content.index(', '+keys[i+1])

      value = content.slice(start_chop,finish_chop - start_chop)
      key = 'contest_type' if key == 'contesttype'
      shell[key] = value
    end

    return shell
  end

  def self.getFeed(url)
    result = Hash.from_xml( RestClient.get url )
    return result['feed']['entry']
  end

end