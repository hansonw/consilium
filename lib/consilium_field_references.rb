module ConsiliumFieldReferences
  def serialize_references
    assocs = get_associations
    assocs.each do |assoc|
      self[assoc] = []
      self.send(assoc).each do |elem|
        self[assoc].push elem
      end
    end
    self
  end

  def update_references(params)
    retval = {:params => params, :errors => []}

    assocs = get_associations
    assocs.each do |assoc|
      if !params[assoc].nil?
        params[assoc].each do |elem|
          klass = assoc.to_s.singularize.capitalize.constantize

          instance = klass.where(:id => elem[:_id] || elem[:id]).first

          if !instance.nil?
            instance.update(elem)
          else
            instance = klass.new(elem)
          end

          instance[self.class.to_s.downcase + "_id"] = self[:_id]

          if !instance.save
            retval[:errors].push instance.errors
          end
        end

        params.delete(assoc)
      end
    end

    self.reload_relations
    retval
  end

  private
    def get_associations
      self.reflect_on_all_associations(:has_many).map(&:name)
    end
end
