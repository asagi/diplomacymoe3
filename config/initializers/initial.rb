class Initial < Settingslogic
  source Rails.root.join('config', 'initial.yml');
  namespace Rails.env
end

