class Person < ActiveRecord::Base
  after_create do
    PREDICTIONIO.acreate_item(self.uid, ["person"])
  end
end
