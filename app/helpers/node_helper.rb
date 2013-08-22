module NodeHelper
  def node_tag(name, opts = {})
    raw "node='#{name}' ng-controller='AnonymousCtrl'
         #{opts[:root] && 'root'}
         #{opts[:field] && 'field'}
         #{opts[:shadow] && 'shadow'}
         #{opts[:writeNode] && 'write-node'}
         #{!opts[:syncable].nil? && 'syncable'}"
  end
end
