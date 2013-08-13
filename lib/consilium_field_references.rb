module ConsiliumFieldReferences
  def serialize_references
    assocs = get_associations
    assocs.each do |assoc|
      puts "***"
      puts assoc
      puts self[assoc]
      puts self.inspect
      puts "###"
      puts self.send(assoc)
      puts "!!!!"
      self[assoc] = []
      self.send(assoc).each do |elem|
        self[assoc].push elem
      end
    end
  end

  def deserialize_references
    assocs = get_associations
    assocs.each do |assoc|
      self.assoc = []
      self[assoc].each do |elem|
        self.assoc.push elem
      end
    end
  end

  private
    def get_associations
      self.reflect_on_all_associations(:has_many).map(&:name)
    end
end
