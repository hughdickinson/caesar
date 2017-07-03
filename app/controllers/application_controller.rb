class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Basic
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  protect_from_forgery with: :reset_session

  helper_method :credential

  before_action :authenticate!
  before_action :authorize!

  respond_to :html, :json

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def authenticate!
    head :unauthorized unless authenticated?
  rescue JWT::ExpiredSignature
    respond_to do |format|
      format.html do
        reset_session
        redirect_to session_path, alert: "Session expired"
      end

      format.json do
        head :unauthorized
      end
    end
  end

  def authenticated?
    credential.ok?
  end

  def authorize!
    head :forbidden unless authorized?
  end

  def authorized?
    false
  end

  def credential
    token = session_token || bearer_token

    @credential ||= if token
                      Credential.find_or_create_by(token: token) do |credential|
                        if session[:credentials]
                          credential.refresh = session[:credentials]["refresh_token"]
                          credential.expires_at = Time.at(session[:credentials]["expires_at"])
                        end

                        credential.project_ids = credential.fetch_accessible_projects["projects"].map{ |prj| prj["id"] }
                      end
                    else
                      Credential.new
                    end
  end

  def session_token
    session[:credentials] && session[:credentials]["token"]
  end

  def bearer_token
    return unless request.headers['Authorization']

    request.headers['Authorization'].match(/\ABearer (?<token>.*)\Z/)["token"]
  end

  def record_not_found
    head 404
  end
end
