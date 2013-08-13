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
      assoc_ids = (assoc.to_s.singularize + "_ids").to_sym
      params[assoc_ids] = []

      if !params[assoc].nil?
        params[assoc].each do |elem|
          klass = assoc.to_s.singularize.capitalize.constantize

          instance = nil
          begin
            instance = klass.find(elem[:_id])
          rescue
          end

          if !instance.nil?
            instance.update(elem)
          else
            instance = klass.new(elem)
          end

          puts self[:_id]
          instance[self.class.to_s.downcase + "_id"] = self[:_id]

          if instance.save
            params[assoc_ids].push elem[:_id]
          else
            retval[:errors].push instance.errors
          end
        end

        params.delete(assoc)
      end
    end

    retval
  end

  private
    def get_associations
      self.reflect_on_all_associations(:has_many).map(&:name)
    end
end
