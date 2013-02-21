def json_fixture(file = 'api.json')
  fp = File.expand_path('../fixtures', __FILE__)
  File.read(File.join(fp, file))
end
