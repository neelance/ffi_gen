# Generated by ffi-gen. Please do not change this file by hand.

require 'ffi'

module CEF
  extend FFI::Library
  ffi_lib 'cef'
  
  def self.attach_function(name, *_)
    begin; super; rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end
  
  # (Not documented)
  class Browser < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class Browser < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class Browser < FFI::Struct
    layout :dummy, :char
  end
  
  # Implement this structure to handle events related to focus. The functions of
  # this structure will be called on the UI thread.
  # 
  # = Fields:
  # :base ::
  #   (unknown) Base structure.
  # :on_take_focus ::
  #   (FFI::Pointer(*)) Called when the browser component is about to loose focus. For instance, if
  #   focus was on the last HTML element and the user pressed the TAB key. |next|
  #   will be true (1) if the browser is giving focus to the next component and
  #   false (0) if the browser is giving focus to the previous component.
  # :on_set_focus ::
  #   (FFI::Pointer(*)) Called when the browser component is requesting focus. |source| indicates
  #   where the focus request is originating from. Return false (0) to allow the
  #   focus to be set or true (1) to cancel setting the focus.
  # :on_got_focus ::
  #   (FFI::Pointer(*)) Called when the browser component has received focus.
  class FocusHandler < FFI::Struct
    layout :base, :char,
           :on_take_focus, :pointer,
           :on_set_focus, :pointer,
           :on_got_focus, :pointer
  end
  
end
