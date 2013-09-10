module ConsiliumFieldReferences
  # Converts references from object.referenceCollection to
  # object[:referenceCollection]. Don't save after using this. In general, this
  # should only be used for presentation purposes (i.e. turning into JSON for
  # the client).
  def serialize_references(syncable = false)
    assocs = get_associations
    assocs.each do |assoc|
      assoc = assoc.to_s.underscore.to_sym

      if syncable
        self[assoc] = {
          :updated_at => nil,
          :created_at => nil,
          :value => [],
        }
      else
        self[assoc] = []
      end

      self.send(assoc).each do |elem|
        if syncable
          self[assoc][:value].push elem
        else
          self[assoc].push elem
        end
      end
    end
    self
  end

  def update_references(params, syncable = false)
    retval = {:params => params, :errors => []}

    assocs = get_associations
    assocs.each do |assoc|
      assoc = assoc.to_s.underscore.to_sym

      existing =
        if syncable
          params[assoc].andand[:value]
        else
          params[assoc]
        end

      # Check for elements that are on the saved model, but not on the params.
      # This means that the updated params must have included a deletion.
      self.send(assoc).each do |elem|
        if !existing.nil?
          found = existing.select do |param|
            (param[:_id] || param[:id]).to_s == (elem[:_id] || elem[:id]).to_s
          end
          # No matching object was found. Delete it.
          elem.destroy if found.empty?
        else
          elem.destroy
        end
      end

      # Check for elements that are on the params. This includes anything
      # that either hasn't been changed, has been updated, or has been created.
      if !existing.nil?
        existing.each do |elem|
          klass = assoc.to_s.camelize.singularize.constantize

          instance = klass.where(:id => elem[:_id] || elem[:id]).first

          if !instance.nil?
            instance.update(elem)
          else
            instance = klass.new(elem)
          end

          instance[self.class.to_s.underscore + "_id"] = self[:_id]

          if !instance.save
            retval[:errors].push instance.errors
          end
        end
      end

      params.delete(assoc)
    end

    self.reload_relations
    retval
  end

  private
    def get_associations
      self.reflect_on_all_associations(:has_many).map(&:name)
    end
end
