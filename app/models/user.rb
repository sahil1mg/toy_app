class User < ApplicationRecord
    attr_accessor :remember_token, :admin, :activation_token, :password_reset_token
    alias :admin? :admin
    before_save { email.downcase! }
    before_create {create_activation_token}
    has_many :microposts, dependent: :destroy
    has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
    has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :name, presence:true
    validates :email, presence:true, format: { with: VALID_EMAIL_REGEX}, uniqueness:{case_sensitive:false}
    validates :password, presence:true, length: { minimum: 6 }
    validates :password_confirmation, presence:true, length: { minimum: 6 }
    has_secure_password

    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # Activates an account.
    def activate
        update_attributes(activated: true, activated_at: Time.zone.now)
    end

    # Sends activation email.
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    def create_reset_digest
        self.password_reset_token = User.new_token
        reset_digest = User.digest(password_reset_token)
        update_attributes(reset_digest: reset_digest, resent_at: Time.zone.now)
    end

    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # Defines a proto-feed.
    # See "Following users" for the full implementation.
    def feed
        #Micropost.where("user_id = ?", id)
        following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
    end

    # Follows a user.
    def follow(other_user)
        following << other_user
    end

    # Unfollows a user.
    def unfollow(other_user)
        following.delete(other_user)
    end

    # Returns true if the current user is following the other user.
    def following?(other_user)
        following.include?(other_user)
    end

    private

    # Returns the hash digest of the given string.
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def self.new_token
        SecureRandom.urlsafe_base64
    end

    def create_activation_token
        self.activation_token  = User.new_token
        self.activation_digest = User.digest(activation_token)
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
end
