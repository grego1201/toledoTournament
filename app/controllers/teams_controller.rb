class TeamsController < ApplicationController
  def index
    @teams = Team.all
    @fencers_without_team = Fencer.without_team

    filter_params = params.permit(:team_name, :fencer_name, :surname, :club, :nationality)
    @old_params = filter_params

    @teams = @teams.where("lower(name) ILIKE ?", "%#{filter_params[:team_name]}%") unless filter_params[:team_name].blank?
    @teams = @teams.joins(:fencers).where("lower(fencers.name) ILIKE ?", "%#{filter_params[:fencer_name]}%") unless filter_params[:fencer_name].blank?
    @teams = @teams.joins(:fencers).where("lower(fencers.surname) ILIKE ?", "%#{filter_params[:surname]}%") unless filter_params[:surname].blank?
    @teams = @teams.joins(:fencers).where("lower(fencers.club) ILIKE ?", "%#{filter_params[:club]}%") unless filter_params[:club].blank?
    @teams = @teams.joins(:fencers).where("lower(fencers.nationality) ILIKE ?", "%#{filter_params[:nationality]}%") unless filter_params[:nationality].blank?

    @teams.sort
  end

  def show
    @team = Team.find(params[:id])
  end

  def new
    @team = Team.new
    @fencers = prepare_fencers_select
  end

  def create
    @team = Team.new(fencer_ids: [safe_params['fencer2'].to_i, safe_params['fencer1'].to_i])
    @fencers = prepare_fencers_select

    if @team.save
      redirect_to @team
    else
      render :new
    end
  end

  def edit
    @team = Team.find(params[:id])
    @fencers = prepare_fencers_select
  end

  def update
    @team = Team.find(params[:id])
    @fencers = prepare_fencers_select

    if @team.update(fencer_ids: [safe_params['fencer1'].to_i, safe_params['fencer2'].to_i])
      redirect_to @team
    else
      render :new
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.fencers.each do |fencer|
      fencer.update_column(:team_id, nil)
    end
    @team.destroy

    redirect_to teams_path
  end

  def generate_random_teams
    Team.destroy_all
    Poule.destroy_all
    EliminationGroup.destroy_all

    Fencer.where.not(team_id: nil).update_all(team_id: nil)

    clubs = {}
    Fencer.all.each do |fencer|
      clubs[fencer.club] = [] if clubs[fencer.club].nil?
      clubs[fencer.club] << fencer.id
    end

    while clubs.length > 1 do
      max_number = clubs.length - 1
      first_club = [*0..max_number].sample
      if first_club == 0
        second_club = [*1..max_number].sample
      elsif first_club == max_number
        second_club = [*0..max_number - 1].sample
      else
        second_club = [*0..first_club - 1, *first_club + 1..max_number].sample
      end

      first_club_key = clubs.keys[first_club]
      first_fencer = clubs[first_club_key].sample
      clubs[first_club_key].delete(first_fencer)

      second_club_key = clubs.keys[second_club]
      second_fencer = clubs[second_club_key].sample
      clubs[second_club_key].delete(second_fencer)

      clubs.except!(first_club_key) if clubs[first_club_key].size.zero?
      clubs.except!(second_club_key) if clubs[second_club_key].size.zero?

      team_name = obtain_available_team_name

      Team.create(fencer_ids: [first_fencer, second_fencer], name: team_name)
    end

    if clubs.length > 0
      same_team_fencers = clubs.first.second
      while same_team_fencers.size > 1 do
        first_fencer = same_team_fencers.sample
        same_team_fencers.delete(first_fencer)
        second_fencer = same_team_fencers.sample
        same_team_fencers.delete(second_fencer)

        team_name = obtain_available_team_name

        Team.create(fencer_ids: [first_fencer, second_fencer], name: team_name)
      end
    end

    redirect_to teams_path
  end

  private

  def safe_params
    params.require(:team).permit(:fencer1, :fencer2)
  end

  def prepare_fencers_select
    without_team_ids = Fencer.without_team.ids
    fencer_ids = @team&.fencer_ids + without_team_ids
    Fencer.where(id: fencer_ids)
  end

  def obtain_available_team_name
    names_with_team = Team.all.pluck(:name)
    available_team_names = Team::NAMES - names_with_team
    available_team_names&.sample
  end
end
