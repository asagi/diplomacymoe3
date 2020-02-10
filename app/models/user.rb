# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_token

  def self.find_or_create_from_auth(auth)
    params = authenticated_user_params(auth)
    user = User.find_by(uid: params[:uid])
    if user
      user.attributes = params
      user.save!
    else
      # レコード作成時のみ表示名を Twitter から取得
      params[:nickname] = auth[:info][:nickname]
      user = User.create(params)
    end
    user
  end

  def self.authenticated_user_params(auth)
    {
      # プロバイダ
      provider: auth[:provider],
      # UID
      uid: auth[:uid],
      # スクリーン名
      nickname: auth[:info][:nickname],
      # 名前
      name: auth[:info][:name],
      # 画像
      image_url: auth[:extra][:raw_info][:profile_image_url_https],
      # URL
      url: auth[:info][:urls][:Twitter]
    }
  end
end
