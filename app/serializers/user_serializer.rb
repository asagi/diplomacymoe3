# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :uid, :nickname, :name, :url, :image_url, :token
end
