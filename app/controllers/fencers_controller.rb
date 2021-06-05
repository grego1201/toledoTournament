class FencersController < ApplicationController
  def index
    filter_params = params.permit(:name, :surname, :club, :nationality)
    @fencers = Fencer.page(params[:page] || 1).per(params[:per_page] || 25)
    @old_params = filter_params
    @fencers = @fencers.where("lower(name) ILIKE ?", "%#{filter_params[:name].downcase}%") unless filter_params[:name].blank?
    @fencers = @fencers.where("lower(surname) ILIKE ?", "%#{filter_params[:surname].downcase}%") unless filter_params[:surname].blank?
    @fencers = @fencers.where("lower(club) ILIKE ?", "%#{filter_params[:club].downcase}%") unless filter_params[:club].blank?
    @fencers = @fencers.where("lower(nationality) ILIKE ?", "%#{filter_params[:nationality].downcase}%") unless filter_params[:nationality].blank?

    @per_page = @old_params[:per_page] || 25
    @pages = Fencer.count % @per_page
  end

  def show
    @fencer = Fencer.find(params[:id])
    @team = @fencer.team
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
      @export_text += "#{fencer.name},#{fencer.surname},#{fencer.club},#{fencer.nationality};"
    end

    @old_params = {}

    @fencers = Fencer.page(params[:page] || 1).per(params[:per_page] || 25)
    @per_page = @old_params[:per_page] || 25
    @pages = Fencer.count % @per_page

    render :index
  end

  def export_file
    file_path = "tmp/test_#{Time.now.to_i}.csv"
    CSV.open(file_path, "w") do |csv|
      Fencer.all.each do |fencer|
        csv << [fencer.name, fencer.surname, fencer.club, fencer.nationality]
      end
    end

    send_file(file_path)
  end

  def import
    @fencers = Fencer.all

    render :import_fencers
  end

  def import_text
    fencers_param = params.require(:users_import)
    splitted_fencers = fencers_param.split(';')
    splitted_fencers = splitted_fencers.map { |fencer| fencer.split(',')}
    create_fencers_from_import(splitted_fencers)

    redirect_to fencers_path
  end

  def import_file
    file = params.require(:users_import).tempfile
    file_content = CSV.read(file.path)
    create_fencers_from_import(file_content)

    redirect_to fencers_path
  end

  private

  def safe_params
    params.require(:fencer).permit(:name, :surname, :nationality, :club)
  end

  def create_fencers_from_import(fencer_attrs)
    fencer_attrs.each do |attrs|
      fencer_attr = {}
      fencer_attr[:name] = attrs[0]
      fencer_attr[:surname] = attrs[1]
      fencer_attr[:club] = attrs[2]
      fencer_attr[:nationality] = attrs[3]

      Fencer.create(fencer_attr)
    end
  end
end
