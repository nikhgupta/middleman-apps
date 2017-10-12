module CucumberHelpers
  def development?
    ENV['RACK_ENV'] == 'development'
  end

  def production?
    ENV['RACK_ENV'] == 'production'
  end
end

World(CucumberHelpers)
