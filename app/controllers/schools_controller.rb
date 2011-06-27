class SchoolsController < ApplicationController

  def index
# I will explain this part in a moment.
    if params[:term]
      #@school = School.find(:all,conditions: ['name LIKE ?', "#{params[:term]}%"])
      @school = School.select("targetAreaID, name").where('name LIKE ?', "#{params[:term]}%").limit(6)
    else
      @school = School.limit(6)
    end

    respond_to do |format|  
      format.html # index.html.erb  
# Here is where you can specify how to handle the request for "/school.json"
      format.json { render json: @school.to_json }
    end
  end
end
