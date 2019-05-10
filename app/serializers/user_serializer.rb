class UserSerializer < ActiveModel::Serializer
  attributes :id, :uid, :nickname, :name, :url, :token
end
