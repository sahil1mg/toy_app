class Micropost < ApplicationRecord
    belongs_to :user
    validates :content, length: {maximum:140}

    def to_s
        id.to_s+' '+content
    end
end
