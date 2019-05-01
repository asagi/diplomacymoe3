class Master < Settingslogic
  source Rails.root.join('config', 'master_data.yml');
  namespace Rails.env
end
