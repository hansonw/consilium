module ConsiliumFieldReferences
  def self.included(klass)
    klass.extend ClassMethods
  end

  # Converts references from object.referenceCollection to
  # object[:referenceCollection]. Don't save after using this. In general, this
  # should only be used for presentation purposes (i.e. turning into JSON for
  # the client).
  def serialize_references(syncable = false)
    assocs = self.class.autosynced_references
    assocs.each do |assoc|
      # Convert the association to underscore. e.g. ClientContact -> client_contact
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

  def new_with_references(params, syncable = false)
    self.id = params[:id]
    self.update_with_references(params, syncable)
  end

  def update_with_references(params, syncable = false)
    retval = {:params => params, :errors => []}

    assocs = self.class.autosynced_references
    assocs.each do |assoc|
      # Convert the association to underscore. e.g. ClientContact -> client_contact
      assoc = assoc.to_s.underscore.to_sym

      params_assoc =
        if syncable
          params[assoc].andand[:value]
        else
          params[assoc]
        end

      # Check for elements that are on the saved model, but not on the params.
      # This means that the updated params must have included a deletion.
      self.send(assoc).each do |elem|
        if !params_assoc.nil?
          found = params_assoc.select do |param|
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
      if !params_assoc.nil?
        params_assoc.each do |elem|
          klass = assoc.to_s.camelize.singularize.constantize

          instance = klass.where(:id => elem[:_id] || elem[:id]).first

          if !instance.nil?
            instance.update(elem)
            relation = self.send(assoc).select { |existing_elem| (existing_elem[:id] || existing_elem[:_id]) == (instance[:id] || instance[:_id]) }
            relation = instance
            if !relation.save
              retval[:errors].push relation.errors
            end
          else
            instance = klass.new(elem)
            if instance.save
              self.send(assoc).push(instance)
            else
              retval[:errors].push instance.errors
            end
          end
        end
      end

      params.delete(assoc)
    end

    self.update(params)
    self.reload_relations
    retval
  end

  module ClassMethods
    def autosync_references(ref)
      (@autosynced_references ||= []).push ref
    end

    def autosynced_references
      @autosynced_references
    end
  end
end
