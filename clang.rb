require 'ffi'

class Clang
  extend FFI::Library
  ffi_lib 'clang'

  enum :availability_kind, [
    :available,
    :deprecated,
    :not_available,
    :not_accessible
  ]

  class String < FFI::Struct
    layout :data, :pointer,
           :private_flags, :uint
  end

  attach_function :get_c_string, :clang_getCString, [String.by_value], :string

  attach_function :dispose_string, :clang_disposeString, [String.by_value], :void

  attach_function :create_index, :clang_createIndex, [:int, :int], :pointer

  attach_function :dispose_index, :clang_disposeIndex, [:pointer], :void

  attach_function :get_file_name, :clang_getFileName, [:pointer], String.by_value

  attach_function :get_file_time, :clang_getFileTime, [:pointer], :long

  attach_function :is_file_multiple_include_guarded, :clang_isFileMultipleIncludeGuarded, [:pointer, :pointer], :uint

  attach_function :get_file, :clang_getFile, [:pointer, :string], :pointer

  class SourceLocation < FFI::Struct
    layout :ptr_data, [:pointer, 2],
           :int_data, :uint
  end

  class SourceRange < FFI::Struct
    layout :ptr_data, [:pointer, 2],
           :begin_int_data, :uint,
           :end_int_data, :uint
  end

  attach_function :get_null_location, :clang_getNullLocation, [], SourceLocation.by_value

  attach_function :equal_locations, :clang_equalLocations, [SourceLocation.by_value, SourceLocation.by_value], :uint

  attach_function :get_location, :clang_getLocation, [:pointer, :pointer, :uint, :uint], SourceLocation.by_value

  attach_function :get_location_for_offset, :clang_getLocationForOffset, [:pointer, :pointer, :uint], SourceLocation.by_value

  attach_function :get_null_range, :clang_getNullRange, [], SourceRange.by_value

  attach_function :get_range, :clang_getRange, [SourceLocation.by_value, SourceLocation.by_value], SourceRange.by_value

  attach_function :equal_ranges, :clang_equalRanges, [SourceRange.by_value, SourceRange.by_value], :uint

  attach_function :range_is_null, :clang_Range_isNull, [SourceRange.by_value], :int

  attach_function :get_presumed_location, :clang_getPresumedLocation, [SourceLocation.by_value, :pointer, :pointer, :pointer], :void

  attach_function :get_instantiation_location, :clang_getInstantiationLocation, [SourceLocation.by_value, :pointer, :pointer, :pointer, :pointer], :void

  attach_function :get_spelling_location, :clang_getSpellingLocation, [SourceLocation.by_value, :pointer, :pointer, :pointer, :pointer], :void

  attach_function :get_range_start, :clang_getRangeStart, [SourceRange.by_value], SourceLocation.by_value

  attach_function :get_range_end, :clang_getRangeEnd, [SourceRange.by_value], SourceLocation.by_value

  enum :diagnostic_severity, [
    :ignored, 0,
    :note, 1,
    :warning, 2,
    :error, 3,
    :fatal, 4
  ]

  attach_function :get_num_diagnostics, :clang_getNumDiagnostics, [:pointer], :uint

  attach_function :get_diagnostic, :clang_getDiagnostic, [:pointer, :uint], :pointer

  attach_function :dispose_diagnostic, :clang_disposeDiagnostic, [:pointer], :void

  enum :diagnostic_display_options, [
    :display_source_location, 0x01,
    :display_column, 0x02,
    :display_source_ranges, 0x04,
    :display_option, 0x08,
    :display_category_id, 0x10,
    :display_category_name, 0x20
  ]

  attach_function :format_diagnostic, :clang_formatDiagnostic, [:pointer, :uint], String.by_value

  attach_function :default_diagnostic_display_options, :clang_defaultDiagnosticDisplayOptions, [], :uint

  attach_function :get_diagnostic_severity, :clang_getDiagnosticSeverity, [:pointer], :diagnostic_severity

  attach_function :get_diagnostic_location, :clang_getDiagnosticLocation, [:pointer], SourceLocation.by_value

  attach_function :get_diagnostic_spelling, :clang_getDiagnosticSpelling, [:pointer], String.by_value

  attach_function :get_diagnostic_option, :clang_getDiagnosticOption, [:pointer, :pointer], String.by_value

  attach_function :get_diagnostic_category, :clang_getDiagnosticCategory, [:pointer], :uint

  attach_function :get_diagnostic_category_name, :clang_getDiagnosticCategoryName, [:uint], String.by_value

  attach_function :get_diagnostic_num_ranges, :clang_getDiagnosticNumRanges, [:pointer], :uint

  attach_function :get_diagnostic_range, :clang_getDiagnosticRange, [:pointer, :uint], SourceRange.by_value

  attach_function :get_diagnostic_num_fix_its, :clang_getDiagnosticNumFixIts, [:pointer], :uint

  attach_function :get_diagnostic_fix_it, :clang_getDiagnosticFixIt, [:pointer, :uint, :pointer], String.by_value

  attach_function :get_translation_unit_spelling, :clang_getTranslationUnitSpelling, [:pointer], String.by_value

  attach_function :create_translation_unit_from_source_file, :clang_createTranslationUnitFromSourceFile, [:pointer, :string, :int, :pointer, :uint, :pointer], :pointer

  attach_function :create_translation_unit, :clang_createTranslationUnit, [:pointer, :string], :pointer

  enum :translation_unit_flags, [
    :none, 0x0,
    :detailed_preprocessing_record, 0x01,
    :incomplete, 0x02,
    :precompiled_preamble, 0x04,
    :cache_completion_results, 0x08,
    :x_precompiled_preamble, 0x10,
    :x_chained_pch, 0x20,
    :nested_macro_expansions, 0x40
  ]

  attach_function :default_editing_translation_unit_options, :clang_defaultEditingTranslationUnitOptions, [], :uint

  attach_function :parse_translation_unit, :clang_parseTranslationUnit, [:pointer, :string, :pointer, :int, :pointer, :uint, :uint], :pointer

  enum :save_translation_unit_flags, [
    :none, 0x0
  ]

  attach_function :default_save_options, :clang_defaultSaveOptions, [:pointer], :uint

  enum :save_error, [
    :none, 0,
    :unknown, 1,
    :translation_errors, 2,
    :invalid_tu, 3
  ]

  attach_function :save_translation_unit, :clang_saveTranslationUnit, [:pointer, :string, :uint], :int

  attach_function :dispose_translation_unit, :clang_disposeTranslationUnit, [:pointer], :void

  enum :reparse_flags, [
    :none, 0x0
  ]

  attach_function :default_reparse_options, :clang_defaultReparseOptions, [:pointer], :uint

  attach_function :reparse_translation_unit, :clang_reparseTranslationUnit, [:pointer, :uint, :pointer, :uint], :int

  enum :tu_resource_usage_kind, [
    :ast, 1,
    :identifiers, 2,
    :selectors, 3,
    :global_completion_results, 4,
    :source_manager_content_cache, 5,
    :ast_side_tables, 6,
    :source_manager_membuffer_malloc, 7,
    :source_manager_membuffer_m_map, 8,
    :external_ast_source_membuffer_malloc, 9,
    :external_ast_source_membuffer_m_map, 10,
    :preprocessor, 11,
    :preprocessing_record, 12,
    :source_manager_data_structures, 13,
    :preprocessor_header_search, 14
  ]

  attach_function :get_tu_resource_usage_name, :clang_getTUResourceUsageName, [:tu_resource_usage_kind], :string

  class TUResourceUsageEntry < FFI::Struct
    layout :kind, :tu_resource_usage_kind,
           :amount, :ulong
  end

  class TUResourceUsage < FFI::Struct
    layout :data, :pointer,
           :num_entries, :uint,
           :entries, :pointer
  end

  attach_function :get_cxtu_resource_usage, :clang_getCXTUResourceUsage, [:pointer], TUResourceUsage.by_value

  attach_function :dispose_cxtu_resource_usage, :clang_disposeCXTUResourceUsage, [TUResourceUsage.by_value], :void

  enum :cursor_kind, [
    :unexposed_decl, 1,
    :struct_decl, 2,
    :union_decl, 3,
    :class_decl, 4,
    :enum_decl, 5,
    :field_decl, 6,
    :enum_constant_decl, 7,
    :function_decl, 8,
    :var_decl, 9,
    :parm_decl, 10,
    :obj_c_interface_decl, 11,
    :obj_c_category_decl, 12,
    :obj_c_protocol_decl, 13,
    :obj_c_property_decl, 14,
    :obj_c_ivar_decl, 15,
    :obj_c_instance_method_decl, 16,
    :obj_c_class_method_decl, 17,
    :obj_c_implementation_decl, 18,
    :obj_c_category_impl_decl, 19,
    :typedef_decl, 20,
    :x_method, 21,
    :namespace, 22,
    :linkage_spec, 23,
    :constructor, 24,
    :destructor, 25,
    :conversion_function, 26,
    :template_type_parameter, 27,
    :non_type_template_parameter, 28,
    :template_template_parameter, 29,
    :function_template, 30,
    :class_template, 31,
    :class_template_partial_specialization, 32,
    :namespace_alias, 33,
    :using_directive, 34,
    :using_declaration, 35,
    :type_alias_decl, 36,
    :obj_c_synthesize_decl, 37,
    :obj_c_dynamic_decl, 38,
    :x_access_specifier, 39,
    :first_ref, 40,
    :obj_c_super_class_ref, 40,
    :obj_c_protocol_ref, 41,
    :obj_c_class_ref, 42,
    :type_ref, 43,
    :x_base_specifier, 44,
    :template_ref, 45,
    :namespace_ref, 46,
    :member_ref, 47,
    :label_ref, 48,
    :overloaded_decl_ref, 49,
    :first_invalid, 70,
    :invalid_file, 70,
    :no_decl_found, 71,
    :not_implemented, 72,
    :invalid_code, 73,
    :first_expr, 100,
    :unexposed_expr, 100,
    :decl_ref_expr, 101,
    :member_ref_expr, 102,
    :call_expr, 103,
    :obj_c_message_expr, 104,
    :block_expr, 105,
    :integer_literal, 106,
    :floating_literal, 107,
    :imaginary_literal, 108,
    :string_literal, 109,
    :character_literal, 110,
    :paren_expr, 111,
    :unary_operator, 112,
    :array_subscript_expr, 113,
    :binary_operator, 114,
    :compound_assign_operator, 115,
    :conditional_operator, 116,
    :c_style_cast_expr, 117,
    :compound_literal_expr, 118,
    :init_list_expr, 119,
    :addr_label_expr, 120,
    :stmt_expr, 121,
    :generic_selection_expr, 122,
    :gnu_null_expr, 123,
    :x_static_cast_expr, 124,
    :x_dynamic_cast_expr, 125,
    :x_reinterpret_cast_expr, 126,
    :x_const_cast_expr, 127,
    :x_functional_cast_expr, 128,
    :x_typeid_expr, 129,
    :x_bool_literal_expr, 130,
    :x_null_ptr_literal_expr, 131,
    :x_this_expr, 132,
    :x_throw_expr, 133,
    :x_new_expr, 134,
    :x_delete_expr, 135,
    :unary_expr, 136,
    :obj_c_string_literal, 137,
    :obj_c_encode_expr, 138,
    :obj_c_selector_expr, 139,
    :obj_c_protocol_expr, 140,
    :obj_c_bridged_cast_expr, 141,
    :pack_expansion_expr, 142,
    :size_of_pack_expr, 143,
    :first_stmt, 200,
    :unexposed_stmt, 200,
    :label_stmt, 201,
    :compound_stmt, 202,
    :case_stmt, 203,
    :default_stmt, 204,
    :if_stmt, 205,
    :switch_stmt, 206,
    :while_stmt, 207,
    :do_stmt, 208,
    :for_stmt, 209,
    :goto_stmt, 210,
    :indirect_goto_stmt, 211,
    :continue_stmt, 212,
    :break_stmt, 213,
    :return_stmt, 214,
    :asm_stmt, 215,
    :obj_c_at_try_stmt, 216,
    :obj_c_at_catch_stmt, 217,
    :obj_c_at_finally_stmt, 218,
    :obj_c_at_throw_stmt, 219,
    :obj_c_at_synchronized_stmt, 220,
    :obj_c_autorelease_pool_stmt, 221,
    :obj_c_for_collection_stmt, 222,
    :x_catch_stmt, 223,
    :x_try_stmt, 224,
    :x_for_range_stmt, 225,
    :seh_try_stmt, 226,
    :seh_except_stmt, 227,
    :seh_finally_stmt, 228,
    :null_stmt, 230,
    :decl_stmt, 231,
    :translation_unit, 300,
    :first_attr, 400,
    :unexposed_attr, 400,
    :ib_action_attr, 401,
    :ib_outlet_attr, 402,
    :ib_outlet_collection_attr, 403,
    :x_final_attr, 404,
    :x_override_attr, 405,
    :annotate_attr, 406,
    :preprocessing_directive, 500,
    :macro_definition, 501,
    :macro_expansion, 502,
    :inclusion_directive, 503
  ]

  class Cursor < FFI::Struct
    layout :kind, :cursor_kind,
           :xdata, :int,
           :data, [:pointer, 3]
  end

  attach_function :get_null_cursor, :clang_getNullCursor, [], Cursor.by_value

  attach_function :get_translation_unit_cursor, :clang_getTranslationUnitCursor, [:pointer], Cursor.by_value

  attach_function :equal_cursors, :clang_equalCursors, [Cursor.by_value, Cursor.by_value], :uint

  attach_function :cursor_is_null, :clang_Cursor_isNull, [Cursor.by_value], :int

  attach_function :hash_cursor, :clang_hashCursor, [Cursor.by_value], :uint

  attach_function :get_cursor_kind, :clang_getCursorKind, [Cursor.by_value], :cursor_kind

  attach_function :is_declaration, :clang_isDeclaration, [:cursor_kind], :uint

  attach_function :is_reference, :clang_isReference, [:cursor_kind], :uint

  attach_function :is_expression, :clang_isExpression, [:cursor_kind], :uint

  attach_function :is_statement, :clang_isStatement, [:cursor_kind], :uint

  attach_function :is_attribute, :clang_isAttribute, [:cursor_kind], :uint

  attach_function :is_invalid, :clang_isInvalid, [:cursor_kind], :uint

  attach_function :is_translation_unit, :clang_isTranslationUnit, [:cursor_kind], :uint

  attach_function :is_preprocessing, :clang_isPreprocessing, [:cursor_kind], :uint

  attach_function :is_unexposed, :clang_isUnexposed, [:cursor_kind], :uint

  enum :linkage_kind, [
    :invalid,
    :no_linkage,
    :internal,
    :unique_external,
    :external
  ]

  attach_function :get_cursor_linkage, :clang_getCursorLinkage, [Cursor.by_value], :linkage_kind

  attach_function :get_cursor_availability, :clang_getCursorAvailability, [Cursor.by_value], :availability_kind

  enum :language_kind, [
    :invalid, 0,
    :c,
    :obj_c,
    :c_plus_plus
  ]

  attach_function :get_cursor_language, :clang_getCursorLanguage, [Cursor.by_value], :language_kind

  attach_function :cursor_get_translation_unit, :clang_Cursor_getTranslationUnit, [Cursor.by_value], :pointer

  attach_function :create_cx_cursor_set, :clang_createCXCursorSet, [], :pointer

  attach_function :dispose_cx_cursor_set, :clang_disposeCXCursorSet, [:pointer], :void

  attach_function :cx_cursor_set_contains, :clang_CXCursorSet_contains, [:pointer, Cursor.by_value], :uint

  attach_function :cx_cursor_set_insert, :clang_CXCursorSet_insert, [:pointer, Cursor.by_value], :uint

  attach_function :get_cursor_semantic_parent, :clang_getCursorSemanticParent, [Cursor.by_value], Cursor.by_value

  attach_function :get_cursor_lexical_parent, :clang_getCursorLexicalParent, [Cursor.by_value], Cursor.by_value

  attach_function :get_overridden_cursors, :clang_getOverriddenCursors, [Cursor.by_value, :pointer, :pointer], :void

  attach_function :dispose_overridden_cursors, :clang_disposeOverriddenCursors, [:pointer], :void

  attach_function :get_included_file, :clang_getIncludedFile, [Cursor.by_value], :pointer

  attach_function :get_cursor, :clang_getCursor, [:pointer, SourceLocation.by_value], Cursor.by_value

  attach_function :get_cursor_location, :clang_getCursorLocation, [Cursor.by_value], SourceLocation.by_value

  attach_function :get_cursor_extent, :clang_getCursorExtent, [Cursor.by_value], SourceRange.by_value

  enum :type_kind, [
    :invalid, 0,
    :unexposed, 1,
    :void, 2,
    :bool, 3,
    :char_u, 4,
    :u_char, 5,
    :char16, 6,
    :char32, 7,
    :u_short, 8,
    :u_int, 9,
    :u_long, 10,
    :u_long_long, 11,
    :u_int128, 12,
    :char_s, 13,
    :s_char, 14,
    :w_char, 15,
    :short, 16,
    :int, 17,
    :long, 18,
    :long_long, 19,
    :int128, 20,
    :float, 21,
    :double, 22,
    :long_double, 23,
    :null_ptr, 24,
    :overload, 25,
    :dependent, 26,
    :obj_c_id, 27,
    :obj_c_class, 28,
    :obj_c_sel, 29,
    :complex, 100,
    :pointer, 101,
    :block_pointer, 102,
    :l_value_reference, 103,
    :r_value_reference, 104,
    :record, 105,
    :enum, 106,
    :typedef, 107,
    :obj_c_interface, 108,
    :obj_c_object_pointer, 109,
    :function_no_proto, 110,
    :function_proto, 111,
    :constant_array, 112
  ]

  class Type < FFI::Struct
    layout :kind, :type_kind,
           :data, [:pointer, 2]
  end

  attach_function :get_cursor_type, :clang_getCursorType, [Cursor.by_value], Type.by_value

  attach_function :equal_types, :clang_equalTypes, [Type.by_value, Type.by_value], :uint

  attach_function :get_canonical_type, :clang_getCanonicalType, [Type.by_value], Type.by_value

  attach_function :is_const_qualified_type, :clang_isConstQualifiedType, [Type.by_value], :uint

  attach_function :is_volatile_qualified_type, :clang_isVolatileQualifiedType, [Type.by_value], :uint

  attach_function :is_restrict_qualified_type, :clang_isRestrictQualifiedType, [Type.by_value], :uint

  attach_function :get_pointee_type, :clang_getPointeeType, [Type.by_value], Type.by_value

  attach_function :get_type_declaration, :clang_getTypeDeclaration, [Type.by_value], Cursor.by_value

  attach_function :get_decl_obj_c_type_encoding, :clang_getDeclObjCTypeEncoding, [Cursor.by_value], String.by_value

  attach_function :get_type_kind_spelling, :clang_getTypeKindSpelling, [:type_kind], String.by_value

  attach_function :get_result_type, :clang_getResultType, [Type.by_value], Type.by_value

  attach_function :get_cursor_result_type, :clang_getCursorResultType, [Cursor.by_value], Type.by_value

  attach_function :is_pod_type, :clang_isPODType, [Type.by_value], :uint

  attach_function :get_array_element_type, :clang_getArrayElementType, [Type.by_value], Type.by_value

  attach_function :get_array_size, :clang_getArraySize, [Type.by_value], :long_long

  attach_function :is_virtual_base, :clang_isVirtualBase, [Cursor.by_value], :uint

  enum :cxx_access_specifier, [
    :x_invalid_access_specifier,
    :x_public,
    :x_protected,
    :x_private
  ]

  attach_function :get_cxx_access_specifier, :clang_getCXXAccessSpecifier, [Cursor.by_value], :cxx_access_specifier

  attach_function :get_num_overloaded_decls, :clang_getNumOverloadedDecls, [Cursor.by_value], :uint

  attach_function :get_overloaded_decl, :clang_getOverloadedDecl, [Cursor.by_value, :uint], Cursor.by_value

  attach_function :get_ib_outlet_collection_type, :clang_getIBOutletCollectionType, [Cursor.by_value], Type.by_value

  enum :child_visit_result, [
    :break,
    :continue,
    :recurse
  ]

  callback :cursor_visitor, [Cursor.by_value, Cursor.by_value, :pointer], :child_visit_result

  attach_function :visit_children, :clang_visitChildren, [Cursor.by_value, :cursor_visitor, :pointer], :uint

  attach_function :get_cursor_usr, :clang_getCursorUSR, [Cursor.by_value], String.by_value

  attach_function :construct_usr_obj_c_class, :clang_constructUSR_ObjCClass, [:string], String.by_value

  attach_function :construct_usr_obj_c_category, :clang_constructUSR_ObjCCategory, [:string, :string], String.by_value

  attach_function :construct_usr_obj_c_protocol, :clang_constructUSR_ObjCProtocol, [:string], String.by_value

  attach_function :construct_usr_obj_c_ivar, :clang_constructUSR_ObjCIvar, [:string, String.by_value], String.by_value

  attach_function :construct_usr_obj_c_method, :clang_constructUSR_ObjCMethod, [:string, :uint, String.by_value], String.by_value

  attach_function :construct_usr_obj_c_property, :clang_constructUSR_ObjCProperty, [:string, String.by_value], String.by_value

  attach_function :get_cursor_spelling, :clang_getCursorSpelling, [Cursor.by_value], String.by_value

  attach_function :get_cursor_display_name, :clang_getCursorDisplayName, [Cursor.by_value], String.by_value

  attach_function :get_cursor_referenced, :clang_getCursorReferenced, [Cursor.by_value], Cursor.by_value

  attach_function :get_cursor_definition, :clang_getCursorDefinition, [Cursor.by_value], Cursor.by_value

  attach_function :is_cursor_definition, :clang_isCursorDefinition, [Cursor.by_value], :uint

  attach_function :get_canonical_cursor, :clang_getCanonicalCursor, [Cursor.by_value], Cursor.by_value

  attach_function :cxx_method_is_static, :clang_CXXMethod_isStatic, [Cursor.by_value], :uint

  attach_function :cxx_method_is_virtual, :clang_CXXMethod_isVirtual, [Cursor.by_value], :uint

  attach_function :get_template_cursor_kind, :clang_getTemplateCursorKind, [Cursor.by_value], :cursor_kind

  attach_function :get_specialized_cursor_template, :clang_getSpecializedCursorTemplate, [Cursor.by_value], Cursor.by_value

  attach_function :get_cursor_reference_name_range, :clang_getCursorReferenceNameRange, [Cursor.by_value, :uint, :uint], SourceRange.by_value

  enum :name_ref_flags, [
    :want_qualifier, 0x1,
    :want_template_args, 0x2,
    :want_single_piece, 0x4
  ]

  enum :token_kind, [
    :punctuation,
    :keyword,
    :identifier,
    :literal,
    :comment
  ]

  class Token < FFI::Struct
    layout :int_data, [:uint, 4],
           :ptr_data, :pointer
  end

  attach_function :get_token_kind, :clang_getTokenKind, [Token.by_value], :token_kind

  attach_function :get_token_spelling, :clang_getTokenSpelling, [:pointer, Token.by_value], String.by_value

  attach_function :get_token_location, :clang_getTokenLocation, [:pointer, Token.by_value], SourceLocation.by_value

  attach_function :get_token_extent, :clang_getTokenExtent, [:pointer, Token.by_value], SourceRange.by_value

  attach_function :tokenize, :clang_tokenize, [:pointer, SourceRange.by_value, :pointer, :pointer], :void

  attach_function :annotate_tokens, :clang_annotateTokens, [:pointer, :pointer, :uint, :pointer], :void

  attach_function :dispose_tokens, :clang_disposeTokens, [:pointer, :pointer, :uint], :void

  attach_function :get_cursor_kind_spelling, :clang_getCursorKindSpelling, [:cursor_kind], String.by_value

  attach_function :get_definition_spelling_and_extent, :clang_getDefinitionSpellingAndExtent, [Cursor.by_value, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :void

  attach_function :enable_stack_traces, :clang_enableStackTraces, [], :void

  attach_function :execute_on_thread, :clang_executeOnThread, [:pointer, :pointer, :uint], :void

  class CompletionResult < FFI::Struct
    layout :cursor_kind, :cursor_kind,
           :completion_string, :pointer
  end

  enum :completion_chunk_kind, [
    :optional,
    :typed_text,
    :text,
    :placeholder,
    :informative,
    :current_parameter,
    :left_paren,
    :right_paren,
    :left_bracket,
    :right_bracket,
    :left_brace,
    :right_brace,
    :left_angle,
    :right_angle,
    :comma,
    :result_type,
    :colon,
    :semi_colon,
    :equal,
    :horizontal_space,
    :vertical_space
  ]

  attach_function :get_completion_chunk_kind, :clang_getCompletionChunkKind, [:pointer, :uint], :completion_chunk_kind

  attach_function :get_completion_chunk_text, :clang_getCompletionChunkText, [:pointer, :uint], String.by_value

  attach_function :get_completion_chunk_completion_string, :clang_getCompletionChunkCompletionString, [:pointer, :uint], :pointer

  attach_function :get_num_completion_chunks, :clang_getNumCompletionChunks, [:pointer], :uint

  attach_function :get_completion_priority, :clang_getCompletionPriority, [:pointer], :uint

  attach_function :get_completion_availability, :clang_getCompletionAvailability, [:pointer], :availability_kind

  attach_function :get_completion_num_annotations, :clang_getCompletionNumAnnotations, [:pointer], :uint

  attach_function :get_completion_annotation, :clang_getCompletionAnnotation, [:pointer, :uint], String.by_value

  attach_function :get_cursor_completion_string, :clang_getCursorCompletionString, [Cursor.by_value], :pointer

  class CodeCompleteResults < FFI::Struct
    layout :results, :pointer,
           :num_results, :uint
  end

  enum :code_complete_flags, [
    :include_macros, 0x01,
    :include_code_patterns, 0x02
  ]

  enum :completion_context, [
    :unexposed, 0
  ]

  attach_function :default_code_complete_options, :clang_defaultCodeCompleteOptions, [], :uint

  attach_function :code_complete_at, :clang_codeCompleteAt, [:pointer, :string, :uint, :uint, :pointer, :uint, :uint], :pointer

  attach_function :sort_code_completion_results, :clang_sortCodeCompletionResults, [:pointer, :uint], :void

  attach_function :dispose_code_complete_results, :clang_disposeCodeCompleteResults, [:pointer], :void

  attach_function :code_complete_get_num_diagnostics, :clang_codeCompleteGetNumDiagnostics, [:pointer], :uint

  attach_function :code_complete_get_diagnostic, :clang_codeCompleteGetDiagnostic, [:pointer, :uint], :pointer

  attach_function :code_complete_get_contexts, :clang_codeCompleteGetContexts, [:pointer], :ulong_long

  attach_function :code_complete_get_container_kind, :clang_codeCompleteGetContainerKind, [:pointer, :pointer], :cursor_kind

  attach_function :code_complete_get_container_usr, :clang_codeCompleteGetContainerUSR, [:pointer], String.by_value

  attach_function :code_complete_get_obj_c_selector, :clang_codeCompleteGetObjCSelector, [:pointer], String.by_value

  attach_function :get_clang_version, :clang_getClangVersion, [], String.by_value

  attach_function :toggle_crash_recovery, :clang_toggleCrashRecovery, [:uint], :void

  callback :inclusion_visitor, [:pointer, :uint, :pointer], :pointer

  attach_function :get_inclusions, :clang_getInclusions, [:pointer, :inclusion_visitor, :pointer], :void

  attach_function :get_remappings, :clang_getRemappings, [:string], :pointer

  attach_function :remap_get_num_files, :clang_remap_getNumFiles, [:pointer], :uint

  attach_function :remap_get_filenames, :clang_remap_getFilenames, [:pointer, :uint, :pointer, :pointer], :void

  attach_function :remap_dispose, :clang_remap_dispose, [:pointer], :void

  enum :visitor_result, [
    :break,
    :continue
  ]

  class CursorAndRangeVisitor < FFI::Struct
    layout :context, :pointer,
           :visit, :pointer
  end

  attach_function :find_references_in_file, :clang_findReferencesInFile, [Cursor.by_value, :pointer, CursorAndRangeVisitor.by_value], :void

end
