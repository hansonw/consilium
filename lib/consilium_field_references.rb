module ConsiliumFieldReferences
  # Converts references from object.referenceCollection to
  # object[:referenceCollection]. Don't save after using this. In general, this
  # should only be used for presentation purposes (i.e. turning into JSON for
  # the client).
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
      # Check for elements that are on the saved model, but not on the params.
      # This means that the updated params must have included a deletion.
      self.send(assoc).each do |elem|
        if !params[assoc].nil?
          existing = params[assoc].select do |param|
            (param[:_id] || param[:id]).to_s == (elem[:_id] || elem[:id]).to_s
          end
          # No matching object was found. Delete it.
          elem.destroy if existing.empty?
        end
      end

      # Check for elements that are on the params. This includes anything
      # that either hasn't been changed, has been updated, or has been created.
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
