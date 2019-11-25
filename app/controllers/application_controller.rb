class ApplicationController < ActionController::Base
  def create
    logger.warm("debug-App")
  end
end
