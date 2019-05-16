FactoryBot.define do
  factory :user do
    sequence(:uid) {|n| 543210 + n }
  end

  factory :master, class: User do
    uid { ENV['MASTER_USER_01'] }
    admin { true }
  end
end
