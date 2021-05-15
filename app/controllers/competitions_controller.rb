class CompetitionsController < ApplicationController
  def index
    @competitions = Competition.all
  end

  def show
    @competition = Competition.find(params[:id])
  end

  def new
    @competition = Competition.new
  end

  def create
    @competition = Competition.new(safe_params)

    if @competition.save
      redirect_to @competition
    else
      render :new
    end
  end

  def edit
    @competition = Competition.find(params[:id])
  end

  def update
    @competition = Competition.find(params[:id])

    if @competition.update(safe_params)
      redirect_to @competition
    else
      render :new
    end
  end

  private

  def safe_params
    params.require(:competition).permit(:name, :date)
  end
end
