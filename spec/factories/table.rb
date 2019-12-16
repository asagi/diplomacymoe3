FactoryBot.define do
  factory :table do
    regulation_id { create(:regulation).id }
  end
end
