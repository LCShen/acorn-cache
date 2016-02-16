class CachedResponse
  DEFAULT_MAX_AGE = 3600

  attr_reader :body, :status

  def initialize(args={})
    @body = args["body"]
    @status = args["status"]
    @headers = args["headers"]
  end

  def fresh?
    Time.now <= expiration_date
  end

  def add_x_from_acorn_cache_header
    headers["X-From-Acorn-Cache"] = "true"
  end

  def to_a
    [status, headers, [body]]
  end

  private

  attr_reader :headers

  def max_age_in_seconds
    headers["Cache-Control"][/\d+/].to_i
  end

  def expiration_date
    if headers["Cache-Control"]
      header_value_to_time("Date") + max_age_in_seconds
    elsif headers["Expiration"]
      header_value_to_time("Expiration")
    else
      header_value_to_time("Date") + DEFAULT_MAX_AGE
    end
  end

  def header_value_to_time(header)
    headers[header].to_time
  end
end
