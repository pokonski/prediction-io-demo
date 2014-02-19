class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :person, foreign_key: :person_uid,
    primary_key: :uid
end
