require "sqlite3"
require "bcrypt"
require_relative "database_helper"

# --- CLASSES ---

class USERACCOUNT
  attr_accessor :firstName, :lastName, :email, :passwordHash, :phoneNumber, :postalAddress, :accountType

  def initialize(firstName, lastName, email, password, phoneNumber, postalAddress, accountType)
    @firstName     = firstName
    @lastName      = lastName
    @email         = email
    @passwordHash  = BCrypt::Password.create(password).to_s
    @phoneNumber   = phoneNumber
    @postalAddress = postalAddress
    @accountType   = accountType
  end
end

class BEANINSTANCE
  attr_accessor :beanType, :beanBlend, :beanRoast, :currentStock

  def initialize(btype, bblend, broast, currentStock)
    @beanType     = btype
    @beanBlend    = bblend
    @beanRoast    = broast
    @currentStock = currentStock
  end
end