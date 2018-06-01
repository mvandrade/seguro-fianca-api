class Api::V2::TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :done, :deadline, :user_id, :created_at, :updated_at,
  :short_description

  def short_description
    object.description[0..10]
  end

  belongs_to :user
  
end
