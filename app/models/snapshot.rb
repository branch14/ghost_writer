class Snapshot < Document

  after_create :take_snapshot!

  private

  def take_snapshot!
    filename = attachable.new_snapshot_name
    File.open(filename, 'w') do |f| 
      f.puts attachable.aggregated_translations.ya2yaml(:syck_compatible => true)
    end
    puts snapshot = File.new(filename)
    self.attachment = snapshot
    save!
  end

end
