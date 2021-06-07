class Classification < Manager
  # returns an array of classifications
  def list
    url = @server + '/Classification'
    get_all_items(url)
  end

  # returns an array of classification codes
  def codes
    list.map {|e| e['ClassificationIdNumber']['Value'] }
  end
end
