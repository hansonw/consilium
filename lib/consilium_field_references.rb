module ConsiliumFieldReferences
  def self.included(klass)
    klass.extend ClassMethods
  end

  # Checks to make sure at least one field has been marked as autosynced.
  def check_if_autosynced_references
    if self.class.autosynced_references.nil? || self.class.autosynced_references.empty?
      puts "When you include ConsiliumFieldReferences, you must mark a field to
            be autosynced on your model by using |autosync_references :name|"
      return true
    end

    return false
  end

  # Converts references from object.referenceCollection to
  # object[:referenceCollection]. Don't save after using this. In general, this
  # should only be used for presentation purposes (i.e. turning into JSON for
  # the client).
  def serialize_references(syncable = false)
    return nil if self.check_if_autosynced_references

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

  # Creates a new model from a passed hash and creates any references on it as well.
  def new_with_references(params, syncable = false)
    self.id = params[:id]
    self.update_with_references(params, syncable)
  end

  # Updates any references on a model, including all CRUD operations for them.
  def update_with_references(params, syncable = false)
    retval = {:params => params, :errors => []}

    return nil if self.check_if_autosynced_references

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
          else
            instance = klass.new(elem)
            # HACK! Write the id that we expect the main object referred from
            # to get when it is saved. We should really be using the
            # object.relation class methods instead.
            instance[self.class.to_s.underscore + '_id'] = params[:id]
          end

          if !instance.save
            retval[:errors].push instance.errors
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
