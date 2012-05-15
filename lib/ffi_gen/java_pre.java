interface NativeEnum {
    public int toNativeInt();
}

class EnumConverter implements TypeConverter {
    public Class<?> nativeType() {
        return Integer.class;
    }

    public Object fromNative(Object input, FromNativeContext context) {
        int intValue = (Integer) input;

        Class<?> targetClass = context.getTargetType();
        for (Object constant : targetClass.getEnumConstants()) {
            if (((NativeEnum) constant).toNativeInt() == intValue) {
                return constant;
            }
        }

        throw new IllegalArgumentException("No constant with integer value " + intValue + " in enum " + targetClass.getName() + ".");
    }

    public Object toNative(Object input, ToNativeContext context) {
        return ((NativeEnum) input).toNativeInt();
    }
}

class MapFunctionMapper implements FunctionMapper {
    private Map<String, String> map;

    public MapFunctionMapper(Map<String, String> map) {
        this.map = map;
    }

    @Override
    public String getFunctionName(NativeLibrary library, Method method) {
        return map.get(method.getName());
    }
}
