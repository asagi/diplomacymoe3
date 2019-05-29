class ProvinceSerializer < ActiveModel::Serializer
  attributes :id, :code, :power, :supply_center, :name
end
