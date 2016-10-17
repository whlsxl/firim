
module Firim
  class Setup
    def run(options)
      containing = (File.directory?("fastlane") ? 'fastlane' : '.')
      file_path = File.join(containing, 'Firimfile')
      data = generate_firim_file(containing, options)
      setup_firim(file_path, data, containing, options)
    end

    def generate_firim_file(firim_path, options)
      # Generate the final Firimfile here
      firim = File.read("#{Firim::ROOT}/lib/assets/FirimfileDefault")
      firim.gsub!("[[FIRIM_API_TOKEN]]", options[:firim_api_token])
      return firim
    end

    def setup_firim(file_path, data, firim_path, options)
      File.write(file_path, data)

      UI.success("Successfully created new Firimfile at path '#{file_path}'")
    end

  end
end