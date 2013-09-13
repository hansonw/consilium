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
  def serialize_references
    return nil if self.check_if_autosynced_references

    assocs = self.class.autosynced_references
    assocs.each do |assoc|
      assoc_class = assoc.to_s.camelize.singularize.constantize
      syncable = assoc_class.syncable?

      if syncable
        self[assoc] = {
          :updated_at => 0,
          :created_at => nil,
          :value => [],
        }
      else
        self[assoc] = []
      end

      existing_assocs = self.send(assoc) || []
      existing_assocs = [existing_assocs] unless existing_assocs.is_a?(Array)
      existing_assocs.each do |elem|
        elem = elem.serialize_references if defined? elem.serialize_references

        if syncable
          self[assoc][:value].push elem

          if elem[:updated_at].to_i > self[assoc][:updated_at]
            self[assoc][:updated_at] = elem[:updated_at].to_i
          end

          self[assoc][:created_at] ||= elem[:created_at].to_i
          if elem[:created_at].to_i < self[assoc][:created_at]
            self[assoc][:created_at] = elem[:created_at].to_i
          end
        else
          self[assoc].push elem
        end
      end
    end
    self
  end

  # Creates a new model from a passed hash and creates any references on it as well.
  def new_with_references(params)
    self.id = params[:id]
    self.update_with_references(params)
  end

  # Updates any references on a model, including all CRUD operations for them.
  def update_with_references(params)
    retval = {:params => params, :errors => []}

    return nil if self.check_if_autosynced_references

    assocs = self.class.autosynced_references

    params_no_references = params.dup
    assocs.each do |assoc|
      params_no_references.delete assoc
    end

    self.update(params_no_references)
    if !self.save
      retval[:errors].push self.errors
      return retval
    end

    assocs.each do |assoc|
      assoc_class = assoc.to_s.camelize.singularize.constantize
      syncable = assoc_class.syncable?

      params_assoc =
        if syncable
          params[assoc].andand[:value]
        else
          params[assoc]
        end || []
      params_assoc = [params_assoc] unless params_assoc.is_a?(Array)

      # Check for elements that are on the saved model, but not on the params.
      # This means that the updated params must have included a deletion.
      existing_assocs = self.send(assoc) || []
      existing_assocs = [existing_assocs] unless existing_assocs.is_a?(Array)
      existing_assocs.each do |elem|
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
      params_assoc.each do |elem|
        klass = assoc.to_s.camelize.singularize.constantize

        instance = klass.where(:id => elem[:_id] || elem[:id]).first

        if !instance.nil?
          if defined? instance.update_with_references
            filtered_elem = instance.update_with_references(elem)
            retval[:errors] |= filtered_elem[:errors]
          else
            instance.update(elem)
          end
        else
          instance = klass.new(:id => (elem[:_id] || elem[:id]))
          # HACK! Write the id that we expect the main object referred from
          # to get when it is saved. We should really be using the
          # object.relation class methods instead.
          instance[self.class.to_s.underscore + '_id'] = params[:id]
          if defined? instance.new_with_references
            filtered_elem = instance.new_with_references(elem)
            retval[:errors] |= filtered_elem[:errors]
          else
            instance.update(elem)
          end
        end

        if !instance.save
          retval[:errors].push instance.errors
        else
          instance.reload_relations
        end
      end
    end

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
