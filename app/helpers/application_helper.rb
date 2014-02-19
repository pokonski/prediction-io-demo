module ApplicationHelper

  def similar_photos
    begin
      PREDICTIONIO.identify(current_user.uid)
      PREDICTIONIO.get_itemsim_top_n("similarity", @person.uid, 5)
    rescue PredictionIO::Client::ItemSimNotFoundError => e
      []
    end
  end

  def recommended_photos
    begin
      PREDICTIONIO.identify(current_user.uid)
      PREDICTIONIO.get_itemrec_top_n("rec", 10)
    rescue PredictionIO::Client::ItemRecNotFoundError => e
      []
    end
  end
end
