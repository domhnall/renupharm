class Services::Response
  attr_reader :errors

  def initialize(errors: [])
    @errors = errors
  end

  def status
    errors.empty? ? :success : nil
  end

  def success?
    status==:success
  end

  def failure?
    !success?
  end
end
