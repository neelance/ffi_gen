# Generated by ffi-gen. Please do not change this file by hand.

require 'ffi'

module ConstVariable
  extend FFI::Library
  def self.attach_function(name, *_)
    begin; super; rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end
  
  CONST_STRING = "abc"
  
  CONST_NUMBER = 123  #0x7b
  
end