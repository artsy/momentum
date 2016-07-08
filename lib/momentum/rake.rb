# Helper to load all rake tasks - to be required in other Rakefiles
Dir.glob(File.expand_path("../../tasks/*.rake", __FILE__)) { |file| load file }
