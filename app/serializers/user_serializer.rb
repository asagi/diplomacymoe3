# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attribute :id
  attribute :uid
  attribute :nickname
  attribute :name
  attribute :url
  attribute :image_url
  attribute :admin
end
