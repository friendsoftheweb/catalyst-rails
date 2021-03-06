namespace :catalyst do
  desc 'Build assets with Catalyst'
  task :build do
    if File.exists?('./public/assets/manifest.json')
      Catalyst.log('Removing previous assets...')

      manifest = JSON.parse(File.read('./public/assets/manifest.json'))

      manifest.values.each do |asset_path|
        system "rm -f ./public/assets/#{asset_path}*"
      end
    end

    Catalyst.log('Compiling assets...')
    Catalyst.build!

    if Catalyst.production?
      Catalyst.log('Removing \'node_modules\' directory...')
      system 'rm -rf ./node_modules'
    end
  end
end
