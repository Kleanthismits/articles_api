module ValidationSerializer
  def self.serialize(errors)
    return if errors.nil?

    json = {}
    new_hash = errors.to_hash(true).map { |k, v|
      v.map do |msg|
        { source: { pointer: "/data/attributes/#{k}" }, detail: msg }
      end
    }.flatten
    json[:errors] = new_hash
    json
  end
end
