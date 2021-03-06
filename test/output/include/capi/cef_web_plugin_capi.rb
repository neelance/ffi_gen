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
  class WebPluginInfoVisitor < FFI::Struct
    layout :dummy, :char
  end
  
  # Visit web plugin information.
  # 
  # @method visit_web_plugin_info(visitor)
  # @param [WebPluginInfoVisitor] visitor 
  # @return [nil] 
  # @scope class
  attach_function :visit_web_plugin_info, :cef_visit_web_plugin_info, [WebPluginInfoVisitor], :void
  
  # Information about a specific web plugin.
  # 
  # = Fields:
  # :base ::
  #   (unknown) Base structure.
  # :get_name ::
  #   (FFI::Pointer(*)) The resulting string must be freed by calling cef_string_userfree_free().
  # :get_path ::
  #   (FFI::Pointer(*)) The resulting string must be freed by calling cef_string_userfree_free().
  # :get_version ::
  #   (FFI::Pointer(*)) The resulting string must be freed by calling cef_string_userfree_free().
  # :get_description ::
  #   (FFI::Pointer(*)) The resulting string must be freed by calling cef_string_userfree_free().
  class WebPluginInfo < FFI::Struct
    layout :base, :char,
           :get_name, :pointer,
           :get_path, :pointer,
           :get_version, :pointer,
           :get_description, :pointer
  end
  
  # Structure to implement for visiting web plugin information. The functions of
  # this structure will be called on the UI thread.
  # 
  # = Fields:
  # :base ::
  #   (unknown) Base structure.
  # :visit ::
  #   (FFI::Pointer(*)) Method that will be called once for each plugin. |count| is the 0-based
  #   index for the current plugin. |total| is the total number of plugins.
  #   Return false (0) to stop visiting plugins. This function may never be
  #   called if no plugins are found.
  class WebPluginInfoVisitor < FFI::Struct
    layout :base, :char,
           :visit, :pointer
  end
  
end
