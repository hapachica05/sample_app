module SessionsHelper
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    # Creates a cookies hash, with the remember_token key (also a hash),
    # which contains the user ID + user salt
    current_user = user
    # creates current_user, which is accessible in both controllers and views
  end

  def current_user=(user)
    # defines a method current_user, and handles the one argument, 
    # user, which is the user to be signed in 
    @current_user = user
    # sets the instance variable, @current_user, and stores the user
    # for later use
  end
  
  def current_user
    @current_user ||= user_from_remember_token
    # sets the @current_user instance variable to user with the 
    # corresponding user token, only if @current_user is undefined
  end
  
  def signed_in?
    !current_user.nil?
    # a user is signed in if the current_user is not nil
  end
  
  def sign_out
    cookies.delete(:remember_token)
    # deletes the :remember_token hash held within a cookie
    current_user = nil
    # changes the current_user back to nil
  end
  
  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
      # authenticates user with the correct user ID and salt. 
      # The * allows for the 2-element remember_token array to be accepted
      # as input for the authenticate_with_salt method, 
      # which typically accepts 2 arguments
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
      # if the :remember_token key of cookies.signed is itself nil, 
      # it will then return an array of [nil, nil]
    end
end
