module ApplicationHelper

  def similar_people(uid)
    begin
      PREDICTIONIO.identify(current_user.uid)
      Person.where(uid: PREDICTIONIO.get_itemsim_top_n("similarity", uid, 25))
    rescue PredictionIO::Client::ItemSimNotFoundError => e
      []
    end
  end

  def recommended_people
    begin
      PREDICTIONIO.identify(current_user.uid)
      Person.where(uid: PREDICTIONIO.get_itemrec_top_n("rec", 10))
    rescue PredictionIO::Client::ItemRecNotFoundError => e
      []
    end
  end
end
