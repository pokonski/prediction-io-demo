class Person < ActiveRecord::Base
  has_many :ratings, foreign_key: :person_uid, primary_key: :uid

  after_create do
    PREDICTIONIO.acreate_item(self.uid, ["person"])
  end
end
