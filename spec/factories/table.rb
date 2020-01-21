# frozen_string_literal: true

FactoryBot.define do
  factory :table do
    regulation_id { create(:regulation).id }
  end
end
