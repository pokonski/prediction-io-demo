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
      people = Person.where(uid: PREDICTIONIO.get_itemrec_top_n("rec", 10))
        .where("not exists (SELECT 1 FROM ratings r WHERE r.person_uid = people.uid AND r.user_id = #{current_user.id})")
      if IGNORED_UIDS.any?
        people = people.where("uid NOT IN (?)", IGNORED_UIDS)
      end
    rescue PredictionIO::Client::ItemRecNotFoundError => e
      []
    end
  end
end
