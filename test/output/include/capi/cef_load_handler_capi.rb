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
  class Frame < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class Browser < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class Frame < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class Browser < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class Frame < FFI::Struct
    layout :dummy, :char
  end
  
  # Implement this structure to handle events related to browser load status. The
  # functions of this structure will be called on the UI thread.
  # 
  # = Fields:
  # :base ::
  #   (unknown) Base structure.
  # :on_load_start ::
  #   (FFI::Pointer(*)) Called when the browser begins loading a frame. The |frame| value will
  #   never be NULL -- call the is_main() function to check if this frame is the
  #   main frame. Multiple frames may be loading at the same time. Sub-frames may
  #   start or continue loading after the main frame load has ended. This
  #   function may not be called for a particular frame if the load request for
  #   that frame fails.
  # :on_load_end ::
  #   (FFI::Pointer(*)) Called when the browser is done loading a frame. The |frame| value will
  #   never be NULL -- call the is_main() function to check if this frame is the
  #   main frame. Multiple frames may be loading at the same time. Sub-frames may
  #   start or continue loading after the main frame load has ended. This
  #   function will always be called for all frames irrespective of whether the
  #   request completes successfully.
  # :on_load_error ::
  #   (FFI::Pointer(*)) Called when the browser fails to load a resource. |errorCode| is the error
  #   code number, |errorText| is the error text and and |failedUrl| is the URL
  #   that failed to load. See net\base\net_error_list.h for complete
  #   descriptions of the error codes.
  class LoadHandler < FFI::Struct
    layout :base, :char,
           :on_load_start, :pointer,
           :on_load_end, :pointer,
           :on_load_error, :pointer
  end
  
end
