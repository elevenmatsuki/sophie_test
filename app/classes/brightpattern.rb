# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative "./curl_builder.rb"

class Brightpattern
  def initialize
    Rails.logger.debug 'Brightpattern-initialize'
    
    c = CurlBuilder.new
    
  end
  
  def query_brightpattern(query)
    Rails.logger.debug 'Brightpattern-query_brightpattern'
    
  end
end
