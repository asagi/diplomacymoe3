class PlayerSerializer < ActiveModel::Serializer
  attributes :id
  attributes :table_id
  belongs_to :user
  attributes :desired_power
  attributes :power
  # attributes :status
  # attributes :registered_at
  # attributes :leaved_at

  def power
    object.power&.symbol || ''
  end
end
