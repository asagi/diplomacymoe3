class Const < Settingslogic
  source Rails.root.join("config", "const.yml")
  namespace Rails.env
end
