class Presenters::ChartPresenter

  class Dataset
    def initialize(label="", data=[])
      @label = label
      @data = data
    end

    def to_h
      { label: @label,
        data: @data }
    end
  end

  def initialize(headers=[], datasets=[])
    @headers = headers
    @datasets = datasets
  end

  def add_dataset(label, data=[])
    @datasets << Dataset.new(label, data)
  end

  def present
    { labels: @headers,
      datasets: @datasets.map(&:to_h) }.to_json
  end
end
