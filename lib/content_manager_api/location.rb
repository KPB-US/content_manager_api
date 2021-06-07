class Location < Manager
  def list
    url = @server + '/Location'
    get_all_items(url)
  end
end
