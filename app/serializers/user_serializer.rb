# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id
  attributes :uid
  attributes :nickname
  attributes :name
  attributes :url
  attributes :image_url
end
