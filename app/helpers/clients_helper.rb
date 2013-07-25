module ClientsHelper
  def getSectionId(index, fields)
    if fields == Client::FIELDS
      return index + 1
    else
      alphas = ('a'..'z').to_a
      return alphas[index]
    end
  end
end
