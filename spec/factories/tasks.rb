FactoryBot.define do
    factory :task do
        title { Faker::Lorem.sentence(3, true, 4) }
        description { Faker::Lorem.paragraph(2, false, 4)}
        deadline { Faker::Date.forward}
        done false
        user
    end
end