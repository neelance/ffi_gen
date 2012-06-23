@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@interface NativeName {
    String value();
}

class NativeNameAnnotationFunctionMapper implements FunctionMapper {
    @Override
    public String getFunctionName(NativeLibrary library, Method method) {
        return method.getAnnotation(NativeName.class).value();
    }
}

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
