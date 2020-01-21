# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_token

  def self.find_or_create_from_auth(auth)
    params = {}
    params[:provider] = auth[:provider]
    # UID
    params[:uid] = auth[:uid]
    # アカウント
    params[:nickname] = auth[:info][:nickname]
    # スクリーン名
    params[:name] = auth[:info][:name]
    # 画像
    params[:image_url] = auth[:info][:image]
    # URL
    params[:url] = auth[:info][:urls][:Twitter]

    user = User.find_by(uid: params[:uid])
    if user
      user.attributes = params
    else
      user = User.create(params)
    end
    user.save!
    user
  end
end
