class FencersController < ApplicationController
  def index
    @fencers = Fencer.all
  end

  def show
    @fencer = Fencer.find(params[:id])
  end

  def new
    @fencer = Fencer.new
  end

  def create
    @fencer = Fencer.new(safe_params)

    if @fencer.save
      redirect_to @fencer
    else
      render :new
    end
  end

  def edit
    @fencer = Fencer.find(params[:id])
  end

  def update
    @fencer = Fencer.find(params[:id])

    if @fencer.update(safe_params)
      redirect_to @fencer
    else
      render :new
    end
  end

  def destroy
    @fencer = Fencer.find(params[:id])
    @fencer.destroy

    redirect_to fencers_path
  end

  private

  def safe_params
    params.require(:fencer).permit(:name, :surname, :second_surname, :nationality, :club)
  end
end
