class EliminationGroupsController < ApplicationController
  def index
    @groups = EliminationGroup.all
  end

  def show
    @group = EliminationGroup.find(params[:id])
    @tableau_size = [8, 4, 2, 1]
    @positions = [*1..8]
    @team_ids = @group.teams.order(:id).collect {|team| ["#{team.fake_id} #{team.name}", team.id]}
  end

  def add_group_result
    @group = EliminationGroup.find(params[:id])

    safe_params = params.permit(:tableau, :position, :team_id)
    old_tableaus = @group.tableaus
    old_tableau = old_tableaus[safe_params[:tableau]] || {}
    old_tableau[safe_params[:position]] = safe_params[:team_id]

    @group.tableaus.merge!({safe_params[:tableau] => old_tableau})
    @group.save

    redirect_to @group
  end

  def add_final_classification
    safe_params = params.permit(:id, :group_classification)
    @group = EliminationGroup.find(safe_params[:id])

    tmp_classification = {}
    safe_params[:group_classification].split(',').each_with_index do |team_id, index|
      tmp_classification[index + 1] = team_id.gsub(' ', '')
    end

    sorted_team_ids = Team.all.sort.pluck(:id)
    final_classification = {}
    tmp_classification.each do |position, value|
      final_classification[position] = sorted_team_ids[value.to_i - 1]
    end

    @group.update_column(:final_classification, final_classification)
    redirect_to final_classification_path
  end

  def final_classification
    @groups = EliminationGroup.all.order(:id)
  end

  def final_classification_to_pdf
    @groups = EliminationGroup.all.order(:id)
    classification_list_text = []

    @groups.each_with_index do |group, index|
      tmp_clas = []

      unless group.final_classification.nil?
        group.final_classification.each_with_index do |content, index|
          _, value = content
          team = Team.find(value)
          tmp_clas << "#{index + 1}. #{team.name}"
          tmp_clas << "#{team.fencer_names}"
        end
      end

      classification_list_text << tmp_clas
    end

    file_path = "tmp/final_classification_#{Time.now.to_i}.pdf"
    Prawn::Document.generate(file_path) do
      move_down(10)

      classification_list_text.each_with_index do |classification, index|
        bounding_box [25,cursor], :width => 600 do
          text "Grupo #{index + 1}. "
        end
        move_down(20)

        classification.each do |c_text|
          bounding_box [25,cursor], :width => 600 do
            text c_text
          end
          move_down(10)
        end

        start_new_page
      end
    end

    send_file(file_path)
  end

  def generate
    EliminationGroup.destroy_all
    classification = PoulesController.new.calculcate_classification
    groups = classification.in_groups(3, false)
    full_size_tableaus = [2, 4, 8, 16, 32, 64, 128, 256]

    groups.each do |group|
      team_ids = group.map(&:first)
      tableau_size = Math.log2(team_ids.count).floor
      tableau_size +=1 unless full_size_tableaus.include?(team_ids.count)
      tableau_size = 2**(tableau_size)

      tableau_teams = {}
      team_ids.each_with_index do |team_id, index|
        tableau_teams[index + 1] = team_id
      end

      tableau_positions = {}
      tableau_positions[tableau_size] = tableau_teams

      EliminationGroup.create(team_ids: team_ids, tableaus: tableau_positions)
    end

    redirect_to elimination_groups_path
  end
end
