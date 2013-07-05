class ChartsController < ApplicationController
  def snapshot
    
  end
  
  def index
    redirect_to snapshot_charts_path
  end
end