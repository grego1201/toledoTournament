class TeamsController < ApplicationController
  def index
    @teams = Team.all
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

    byebug
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


  private

  def safe_params
    params.require(:team).permit(:fencer1, :fencer2)
  end

  def prepare_fencers_select
    without_team_ids = Fencer.without_team.ids
    fencer_ids = @team&.fencer_ids + without_team_ids
    Fencer.where(id: fencer_ids)
  end
end

