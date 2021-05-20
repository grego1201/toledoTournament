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

  def export_text
    @fencers = Fencer.all
    @export_text = ''
    Fencer.all.each do |fencer|
      @export_text += "#{fencer.name},#{fencer.club},#{fencer.surname},#{fencer.second_surname},#{fencer.nationality};"
    end

    render :index
  end

  def export_file
    file_path = "tmp/test_#{Time.now.to_i}.csv"
    CSV.open(file_path, "w") do |csv|
      Fencer.all.each do |fencer|
        csv << [fencer.name, fencer.club, fencer.surname, fencer.second_surname, fencer.nationality]
      end
    end

    send_file(file_path)
  end

  def import_text
  end

  def import_file
  end

  private

  def safe_params
    params.require(:fencer).permit(:name, :surname, :second_surname, :nationality, :club)
  end
end
