class User < ApplicationRecord
    before_save { email.downcase! }
    has_many :microposts
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :name, presence:true
    validates :email, presence:true, format: { with: VALID_EMAIL_REGEX}, uniqueness:{case_sensitive:false}
    validates :password, presence:true, length: { minimum: 6 }
    validates :password_confirmation, presence:true, length: { minimum: 6 }
    has_secure_password
end
