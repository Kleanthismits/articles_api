FactoryBot.define do
  factory :article do
    title { 'Sample title' }
    content { 'Sample content' }
    sequence :slug do |n|
      "#{n}-Sample slug"
    end
    association :user
  end
end
