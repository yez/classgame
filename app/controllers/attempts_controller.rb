class AttemptsController < ApplicationController
  before_action :set_attempt, only: [:show, :edit, :update, :destroy]

  # GET /attempts
  # GET /attempts.json
  def index
    @attempts = Attempt.all
  end

  # GET /attempts/1
  # GET /attempts/1.json
  def show
  end

  # GET /attempts/new
  def new
    @chapter     = Chapter.find(params[:id])
    @@chapter    = @chapter
    
    @@contents ||= @chapter.all_contents
    @partial   ||= @@contents[0][0].class.table_name
    
    if @@contents[0][0].class.table_name == 'exercises'
      @exercise = @@contents[0][0] 
    elsif @@contents[0][0].class.table_name == 'texts'
      @text = @@contents[0][0] 
    else
      @video = @@contents[0][0]
    end
  
    @@contents.delete_at(0)
    #debugger
  end

  # GET /attempts/1/edit
  def edit
  end

  # POST /attempts
  # POST /attempts.json
  def create
    if params[:question][:alternative_attributes]
      points       = 0
      approved     = false
      alternatives = Alternative.where(id: attempt_params)
      alternatives.each do |alternative| 
        if alternative.correct
          points  +=  alternative.question.experience
          approved = true
        else 
          approved = false
        end
      end

      performace             = current_user.performace
      experience_final       = performace.total_experience + points
      amount_exercises_final = performace.amount_exercises + 1
      performace.update_attributes(total_experience: experience_final, amount_exercises: amount_exercises_final)
      
      @attempt = Attempt.new(experience:points, ending_time:Time.now, approved:approved)
      @attempt.user = current_user
      
      respond_to do |format|
        if @attempt.save
          format.html { redirect_to new_attempt_path(@@chapter), notice: 'Attempt was successfully created.' }
          format.json { render :show, status: :created, location: courses_path }
        else
          format.html { render :new }
          format.json { render json: @attempt.errors, status: :unprocessable_entity }
        end
      end
    end  
  end

  # PATCH/PUT /attempts/1
  # PATCH/PUT /attempts/1.json
  def update
    respond_to do |format|
      if @attempt.update(attempt_params)
        format.html { redirect_to @attempt, notice: 'Attempt was successfully updated.' }
        format.json { render :show, status: :ok, location: @attempt }
      else
        format.html { render :edit }
        format.json { render json: @attempt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attempts/1
  # DELETE /attempts/1.json
  def destroy
    @attempt.destroy
    respond_to do |format|
      format.html { redirect_to attempts_url, notice: 'Attempt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attempt
      @attempt = Attempt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attempt_params
      params[:question][:alternative_attributes] = params[:question][:alternative_attributes].map {|attrs| attrs.last } 
      #params.require(:attempt).permit(:experience, :ending_time, :approved, :done)
      #params.require(:question)
    end
end
