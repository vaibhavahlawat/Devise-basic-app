class SakaiLinkController < ApplicationController
  require 'soap/wsdlDriver'
  DRIVERS = {}

  def index
    if (DRIVERS.size == 0)
      # we can't initialize these at the class level because if one of the wsdl
      # verifiers points to the currently starting app, we'll deadlock (aka points to the fake_verify action below)
      init_soap_drivers
    end
    @params = params  # FIXME for the fail view for now
    logout_keeping_session!
    @user = params[:user]
    @internaluser = params[:internaluser]
    @site = params[:site]
    @placement = params[:placement]
    @role = params[:role]
    @session = params[:session]
    @serverurl = params[:serverurl]
    @time = params[:time]
    @sign = params[:sign]
    @query_string = request.query_string
    
    @serverurl << '/' if (@serverurl !~ /\/$/)
    
    driver = DRIVERS[@serverurl]
    success = false
    if driver
      @response = driver.testsign(@query_string)
      logger.warn "Testsign response: '#{@response}'"
      if @response == "success"
        # FIXME We may or may not be mapping the sakai internal unique id to the login field...
        user = User.find_by_login(@internaluser)
        logger.warn("Login (#{@internaluser}) found user: #{user}")
        if user
          self.current_user = user
          session[:original_user_id] = current_user.id
          successful_login
          success = true
        end
      end
    end
    if ! success
      self.current_user = User.anonymous
    end
  end
  
  def fake_verification
    if (ENV['RAILS_ENV'] != 'test' && ENV['RAILS_ENV'] != 'development')
      render :xml => "<not_allowed/>", :layout => false
    else
      response['Content-type'] = 'application/xml'
      # this is a fake verification action to be used when testing the sakai linktool integration\
      if request.method == :post
        # logger.warn "Post: #{request.raw_post}"
        # return the success message
        render 'wsdl_verify', :layout => false
      else
        render 'wsdl_def', :layout => false
      end
    end
  end
  
  private
  
  def init_soap_drivers
    return if ! APP_CONFIG[:valid_sakai_instances]
    APP_CONFIG[:valid_sakai_instances].each do |url|
      begin
        url << '/' if (url !~ /\/$/)
        wsdl = url.clone
        wsdl << 'sakai-axis/SakaiSigning.jws?wsdl'
        driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
        # logger.warn("wsdl for #{url}: #{driver.methods.join(',')}")
        DRIVERS[url] = driver
      rescue WSDL::XMLSchema::Parser::UnknownElementError
        DRIVERS.delete(url)
      end
    end
  end
  
  def successful_login
    new_cookie_flag = false
    handle_remember_cookie! new_cookie_flag
    redirect_to(root_path)
    flash[:notice] = "Logged in successfully"
  end
end
