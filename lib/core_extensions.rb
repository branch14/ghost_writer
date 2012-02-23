module CoreExtensions

  ::Hash.class_eval do

    class MergeConflict < StandardError; end

    # tries to merge hashes deeply,
    # in case of conflicts yields block if given
    def deep_merge(other, &bloc)
      other.keys.inject(dup) do |result, key|
        begin
          case result[key]
          when Hash
            if other[key].is_a?(Hash)
              result[key] = result[key].deep_merge(other[key], &bloc)
              result
            else
              raise MergeConflict
            end
          when nil then result.merge key => other[key]
          else
            raise MergeConflict
          end
        rescue MergeConflict
          if bloc.nil?
            result[key] = other[key]
          else
            result[key] = bloc.call(result, other, key) 
          end
          result
        end
      end
      
    end

  end
end
