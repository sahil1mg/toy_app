module SessionsHelper

    def log_in(user)
        session[:user_id]=user.id
    end

    # Returns the user corresponding to the remember token cookie.
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(:remember, cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    def current_user?(user) 
        current_user == user
    end

    def logged_in?
        !current_user.nil?
    end

    # Logs out the current user.
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    #storing cookie
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # Forgets a persistent session.
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    #Storing last url if user wanted to open an url but couldn't as he/she was not logged
    def store_location
        puts request #checking what it has
        session[:forwarding_url] = request.original_url if request.get?
    end

    #friendly forwarding
    def redirect_back_or(default)
        redirect_to session[:forwarding_url] || default # checks if first is not nil then first else default
        session.delete(:forwarding_url)
    end
end
