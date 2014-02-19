class PeopleController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_person, only: [:show, :vote]
  before_filter :identify_user

  def random
    desired_sex = {"male" => "female", "female" => "male"}
    @person = Person
      .where("not exists (SELECT 1 FROM ratings r WHERE r.person_uid = people.uid AND r.user_id = #{current_user.id})")
      .where(sex: desired_sex[current_user.sex]).order("RANDOM()")

    if IGNORED_UIDS.any?
      @person = @person.where("uid NOT IN (?)", IGNORED_UIDS)
    end

    @person = @person.first
    if @person
      View.where(person_uid: @person.uid, user_id: current_user.id).first_or_create
    end
  end

  def show
    PREDICTIONIO.arecord_action_on_item("view", @person.uid)
  end

  def vote
    rating = Rating.where(person_uid: @person.uid, user_id: current_user.id).first_or_initialize
    rating.number = params[:value]
    rating.save

    PREDICTIONIO.arecord_action_on_item("rate", @person.uid, pio_rate: params[:value].to_i)

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def fetch_friends
    @graph = Koala::Facebook::API.new(current_user.token)

    profile = @graph.get_object("me")
    friends = @graph.get_connections("me", "friends", limit: 1000, fields: "gender,first_name,last_name,picture.height(700)")
    count = 0
    while friends.any?
      friends.each do |friend|
        count += 1
        next if friend["picture"]["data"]["is_silhouette"]
        person = Person.where(uid: friend["id"]).first
        person ||= Person.new
        person.sex = friend["gender"]
        person.first_name = friend["first_name"]
        person.last_name = friend["last_name"]
        person.uid = friend["id"]
        person.image_path = friend["picture"]["data"]["url"]
        person.save
      end
      friends = friends.next_page
    end
    flash[:notice] = "Fetched #{count} of your friends"
    redirect_to people_path
  end

  def top
    ratings = Rating.group(:person_uid).having("avg(number) > 3.5").order("avg(number) DESC").limit(30).average(:number)
    @list = []
    people = Person.where(uid: ratings.keys)
    people.each do |person|
      @list << [person, ratings[person.uid].to_f]
    end
    @list.sort_by! {|n|- n.last }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find_by_uid(params[:id])
    end

    def identify_user
      PREDICTIONIO.identify(current_user.uid) if user_signed_in?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params[:person]
    end
end
