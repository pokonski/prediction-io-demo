class PeopleController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_filter :identify_user

  # GET /persons
  # GET /persons.json
  def index
    ignored = ENV["IGNORED_UIDS"]
    ignored = ignored ? ignored.split(",") : []

    desired_sex = {"male" => "female", "female" => "male"}
    @person = Person
      .where("not exists (SELECT 1 FROM ratings r WHERE r.person_uid = people.uid AND r.user_id = #{current_user.id})")
      .where(sex: desired_sex[current_user.sex]).order("RANDOM()")

    if ignored.any?
      @person = @person.where("uid NOT IN (?)", ignored)
    end

    @person = @person.first
    if @person
      PREDICTIONIO.arecord_action_on_item("view", @person.uid)
      View.where(person_uid: @person.uid, user_id: current_user.id).first_or_create
    end
  end

  # GET /persons/1
  # GET /persons/1.json
  def show
  end

  # GET /persons/new
  def new
    @person = Person.new
  end

  # GET /persons/1/edit
  def edit
  end

  # POST /persons
  # POST /persons.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render action: 'show', status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /persons/1
  # PATCH/PUT /persons/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /persons/1
  # DELETE /persons/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def vote
    @person = Person.where(uid: params[:id]).first

    Rating.create number: params[:value], person_uid: @person.uid,
      user_id: current_user.id

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    def identify_user
      PREDICTIONIO.identify(current_user.uid) if user_signed_in?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params[:person]
    end
end
