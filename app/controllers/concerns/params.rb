# Defines strong parameters so these can be used in both admin and normal controllers
module Params
  module UserParams
    extend ActiveSupport::Concern

    private

    def user_params
      params.require(:user).permit(:login, :username, :name, :email, :password, :password_confirmation, :remember_me, :public)
    end 
  end

  module SettingParams
    extend ActiveSupport::Concern

    included do
    	before_filter :setting_params, :if => Proc.new {|controller| controller.params[:action] =~ /\Aupdate_(\w+_)?settings\z/ }
    end

    private

    def setting_params
      settings = {:name => params.require(:name), :value => params.require(:value)}
      @value = case settings[:value]
        when true
          "1"
        when false
          "0"
        else
          settings[:value]
        end
      @updated_key = settings[:name].to_sym
    end
  end

  module RepoParams
    extend ActiveSupport::Concern

    private

    def repo_params
      params.require(:repository).permit(:name, :public, :description)
    end
  end
end