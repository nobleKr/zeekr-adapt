.class public final Ltop/canyie/pine/Pine;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Ltop/canyie/pine/Pine$HookMode;,
        Ltop/canyie/pine/Pine$LibLoader;,
        Ltop/canyie/pine/Pine$HookHandler;,
        Ltop/canyie/pine/Pine$HookListener;,
        Ltop/canyie/pine/Pine$HookRecord;,
        Ltop/canyie/pine/Pine$CallFrame;
    }
.end annotation


# static fields
.field public static final EMPTY_OBJECT_ARRAY:[Ljava/lang/Object;

.field public static volatile a:Z

.field private static arch:I

.field public static final b:Ljava/util/HashMap;

.field public static final c:Ljava/util/concurrent/ConcurrentHashMap;

.field public static closeElf:J

.field public static final d:Ljava/lang/Object;

.field public static volatile e:I

.field public static f:Ltop/canyie/pine/Pine$HookHandler;

.field public static findElfSymbol:J

.field public static g:Ltop/canyie/pine/Pine$HookListener;

.field public static openElf:J


# direct methods
.method static constructor <clinit>()V
    .locals 3

    const/4 v0, 0x0

    new-array v0, v0, [Ljava/lang/Object;

    sput-object v0, Ltop/canyie/pine/Pine;->EMPTY_OBJECT_ARRAY:[Ljava/lang/Object;

    new-instance v0, Ljava/util/HashMap;

    const/16 v1, 0x8

    const/high16 v2, 0x40000000    # 2.0f

    invoke-direct {v0, v1, v2}, Ljava/util/HashMap;-><init>(IF)V

    sput-object v0, Ltop/canyie/pine/Pine;->b:Ljava/util/HashMap;

    new-instance v0, Ljava/util/concurrent/ConcurrentHashMap;

    invoke-direct {v0}, Ljava/util/concurrent/ConcurrentHashMap;-><init>()V

    sput-object v0, Ltop/canyie/pine/Pine;->c:Ljava/util/concurrent/ConcurrentHashMap;

    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Ltop/canyie/pine/Pine;->d:Ljava/lang/Object;

    new-instance v0, Ltop/canyie/pine/Pine$1;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Ltop/canyie/pine/Pine;->f:Ltop/canyie/pine/Pine$HookHandler;

    return-void
.end method

.method public static a(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    .locals 1

    invoke-interface {p0}, Ljava/lang/reflect/Member;->getDeclaringClass()Ljava/lang/Class;

    move-result-object v0

    invoke-static {p0, p1}, Ltop/canyie/pine/Pine;->syncMethodInfo(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;)V

    invoke-virtual {p1, p2, p3}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    return-object p0
.end method

.method public static b(Ltop/canyie/pine/Pine$HookRecord;IZ)V
    .locals 10

    iget-object v8, p0, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    sget v0, Ltop/canyie/pine/Pine;->e:I

    const/4 v1, 0x0

    const/4 v9, 0x1

    if-eq v0, v9, :cond_1

    const/4 v2, 0x3

    if-ne v0, v2, :cond_0

    goto :goto_0

    :cond_0
    move v2, v1

    goto :goto_1

    :cond_1
    :goto_0
    move v2, v9

    :goto_1
    invoke-static {}, Ltop/canyie/pine/Pine;->currentArtThread0()J

    move-result-wide v3

    invoke-static {p1}, Ljava/lang/reflect/Modifier;->isStatic(I)Z

    move-result v5

    iput-boolean v5, p0, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-eqz v5, :cond_2

    if-eqz p2, :cond_2

    move-object p2, v8

    check-cast p2, Ljava/lang/reflect/Method;

    invoke-static {p2}, Ltop/canyie/pine/Pine;->e(Ljava/lang/reflect/Method;)V

    sget p2, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v5, 0x1d

    if-lt p2, v5, :cond_2

    invoke-static {v3, v4}, Ltop/canyie/pine/Pine;->makeClassesVisiblyInitialized(J)V

    :cond_2
    invoke-interface {v8}, Ljava/lang/reflect/Member;->getDeclaringClass()Ljava/lang/Class;

    move-result-object p2

    invoke-static {p1}, Ljava/lang/reflect/Modifier;->isNative(I)Z

    move-result v6

    invoke-static {p2}, Ljava/lang/reflect/Proxy;->isProxyClass(Ljava/lang/Class;)Z

    move-result v7

    if-eqz v2, :cond_5

    if-nez v6, :cond_4

    if-nez v7, :cond_4

    if-ne v0, v9, :cond_5

    invoke-static {v3, v4, v8}, Ltop/canyie/pine/Pine;->compile0(JLjava/lang/reflect/Member;)Z

    move-result p1

    if-nez p1, :cond_3

    const-string p1, "Pine"

    const-string v0, "Cannot compile the target method, force replacement mode."

    invoke-static {p1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_2

    :cond_3
    move v1, v2

    :cond_4
    :goto_2
    move v5, v1

    goto :goto_3

    :cond_5
    move v5, v2

    :goto_3
    instance-of p1, v8, Ljava/lang/reflect/Method;

    if-eqz p1, :cond_7

    move-object p1, v8

    check-cast p1, Ljava/lang/reflect/Method;

    invoke-virtual {p1}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v0

    iput-object v0, p0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    invoke-virtual {p1}, Ljava/lang/reflect/Method;->getReturnType()Ljava/lang/Class;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Class;->isPrimitive()Z

    move-result v0

    if-eqz v0, :cond_6

    invoke-virtual {p1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p1

    const-string v0, "Bridge"

    invoke-virtual {p1, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    goto :goto_4

    :cond_6
    const-string p1, "objectBridge"

    goto :goto_4

    :cond_7
    move-object p1, v8

    check-cast p1, Ljava/lang/reflect/Constructor;

    invoke-virtual {p1}, Ljava/lang/reflect/Constructor;->getParameterTypes()[Ljava/lang/Class;

    move-result-object p1

    iput-object p1, p0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    const-string p1, "voidBridge"

    :goto_4
    iget-object v0, p0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    array-length v0, v0

    iput v0, p0, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    sget v1, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v2, 0x17

    if-ne v1, v2, :cond_8

    sget v1, Ltop/canyie/pine/Pine;->arch:I

    const/4 v2, 0x2

    if-ne v1, v2, :cond_8

    invoke-static {p1, v0}, Ltop/canyie/pine/entry/Arm64MarshmallowEntry;->getBridge(Ljava/lang/String;I)Ljava/lang/reflect/Method;

    move-result-object p1

    goto :goto_5

    :cond_8
    sget-object v0, Ltop/canyie/pine/Pine;->b:Ljava/util/HashMap;

    invoke-virtual {v0, p1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/reflect/Method;

    :goto_5
    if-eqz p1, :cond_a

    move-wide v0, v3

    move-object v2, p2

    move-object v3, v8

    move-object v4, p1

    invoke-static/range {v0 .. v7}, Ltop/canyie/pine/Pine;->hook0(JLjava/lang/Class;Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;ZZZ)Ljava/lang/reflect/Method;

    move-result-object p1

    if-eqz p1, :cond_9

    invoke-virtual {p1, v9}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    iput-object p1, p0, Ltop/canyie/pine/Pine$HookRecord;->backup:Ljava/lang/reflect/Method;

    return-void

    :cond_9
    new-instance p0, Ljava/lang/RuntimeException;

    new-instance p1, Ljava/lang/StringBuilder;

    const-string p2, "Failed to hook method "

    invoke-direct {p1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_a
    new-instance p0, Ljava/lang/AssertionError;

    new-instance p1, Ljava/lang/StringBuilder;

    const-string p2, "Cannot find bridge method for "

    invoke-direct {p1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw p0
.end method

.method public static c()V
    .locals 14

    const-string v0, "Unexpected arch "

    :try_start_0
    sget v1, Ltop/canyie/pine/Pine;->arch:I

    const/4 v2, 0x2

    const/4 v3, 0x1

    if-ne v1, v2, :cond_0

    const-string v0, "top.canyie.pine.entry.Arm64Entry"

    sget-object v10, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    move-object v4, v10

    move-object v5, v10

    move-object v6, v10

    move-object v7, v10

    move-object v8, v10

    move-object v9, v10

    filled-new-array/range {v4 .. v10}, [Ljava/lang/Class;

    move-result-object v1

    goto :goto_0

    :catch_0
    move-exception v0

    goto :goto_2

    :cond_0
    if-ne v1, v3, :cond_1

    const-string v0, "top.canyie.pine.entry.Arm32Entry"

    sget-object v1, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v1, v1}, [Ljava/lang/Class;

    move-result-object v1

    goto :goto_0

    :cond_1
    const/4 v2, 0x3

    if-ne v1, v2, :cond_3

    const-string v0, "top.canyie.pine.entry.X86Entry"

    sget-object v1, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    filled-new-array {v1, v1, v1}, [Ljava/lang/Class;

    move-result-object v1

    :goto_0
    const-class v2, Ltop/canyie/pine/Pine;

    invoke-virtual {v2}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v2

    invoke-static {v0, v3, v2}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0

    const-string v4, "voidBridge"

    const-string v5, "intBridge"

    const-string v6, "longBridge"

    const-string v7, "doubleBridge"

    const-string v8, "floatBridge"

    const-string v9, "booleanBridge"

    const-string v10, "byteBridge"

    const-string v11, "charBridge"

    const-string v12, "shortBridge"

    const-string v13, "objectBridge"

    filled-new-array/range {v4 .. v13}, [Ljava/lang/String;

    move-result-object v2

    const/4 v4, 0x0

    :goto_1
    const/16 v5, 0xa

    if-ge v4, v5, :cond_2

    aget-object v5, v2, v4

    invoke-virtual {v0, v5, v1}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v6

    invoke-virtual {v6, v3}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    sget-object v7, Ltop/canyie/pine/Pine;->b:Ljava/util/HashMap;

    invoke-virtual {v7, v5, v6}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    add-int/lit8 v4, v4, 0x1

    goto :goto_1

    :cond_2
    return-void

    :cond_3
    new-instance v1, Ljava/lang/RuntimeException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    sget v0, Ltop/canyie/pine/Pine;->arch:I

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :goto_2
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "Failed to init bridge methods"

    invoke-direct {v1, v2, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1
.end method

.method public static native cloneExtras(J)J
.end method

.method public static compile(Ljava/lang/reflect/Member;)Z
    .locals 3

    invoke-interface {p0}, Ljava/lang/reflect/Member;->getModifiers()I

    move-result v0

    invoke-interface {p0}, Ljava/lang/reflect/Member;->getDeclaringClass()Ljava/lang/Class;

    move-result-object v1

    instance-of v2, p0, Ljava/lang/reflect/Method;

    if-nez v2, :cond_1

    instance-of v2, p0, Ljava/lang/reflect/Constructor;

    if-eqz v2, :cond_0

    goto :goto_0

    :cond_0
    new-instance v0, Ljava/lang/IllegalArgumentException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Only methods and constructors can be compiled: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_1
    :goto_0
    invoke-static {v0}, Ljava/lang/reflect/Modifier;->isAbstract(I)Z

    move-result v2

    if-nez v2, :cond_4

    invoke-static {v0}, Ljava/lang/reflect/Modifier;->isNative(I)Z

    move-result v0

    if-nez v0, :cond_3

    invoke-static {v1}, Ljava/lang/reflect/Proxy;->isProxyClass(Ljava/lang/Class;)Z

    move-result v0

    if-eqz v0, :cond_2

    goto :goto_1

    :cond_2
    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    invoke-static {}, Ltop/canyie/pine/Pine;->currentArtThread0()J

    move-result-wide v0

    invoke-static {v0, v1, p0}, Ltop/canyie/pine/Pine;->compile0(JLjava/lang/reflect/Member;)Z

    move-result p0

    return p0

    :cond_3
    :goto_1
    const/4 p0, 0x0

    return p0

    :cond_4
    new-instance v0, Ljava/lang/IllegalArgumentException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Cannot compile abstract methods: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static native compile0(JLjava/lang/reflect/Member;)Z
.end method

.method public static native currentArtThread0()J
.end method

.method public static d()V
    .locals 7

    sget v0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v1, 0x13

    if-lt v0, v1, :cond_8

    const/16 v1, 0x22

    if-ne v0, v1, :cond_3

    sget-object v1, Landroid/os/Build$VERSION;->CODENAME:Ljava/lang/String;

    sget-object v2, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v1, v2}, Ljava/lang/String;->toUpperCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    const-string v3, "REL"

    invoke-virtual {v3, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    goto :goto_0

    :cond_0
    const-string v3, "VanillaIceCream"

    invoke-virtual {v3, v2}, Ljava/lang/String;->toUpperCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/String;->compareTo(Ljava/lang/String;)I

    move-result v1

    if-ltz v1, :cond_3

    sget-boolean v0, Ltop/canyie/pine/PineConfig;->disableHiddenApiPolicy:Z

    if-nez v0, :cond_1

    sget-boolean v0, Ltop/canyie/pine/PineConfig;->disableHiddenApiPolicyForPlatformDomain:Z

    if-eqz v0, :cond_2

    :cond_1
    const-string v0, ""

    filled-new-array {v0}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lorg/lsposed/hiddenapibypass/HiddenApiBypass;->addHiddenApiExemptions([Ljava/lang/String;)Z

    :cond_2
    const/16 v0, 0x23

    :cond_3
    :goto_0
    const-string v1, "java.vm.version"

    invoke-static {v1}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_7

    const-string v2, "2"

    invoke-virtual {v1, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_7

    const/16 v1, 0x1a

    if-ge v0, v1, :cond_4

    const/4 v1, 0x3

    goto :goto_1

    :cond_4
    const/4 v1, 0x2

    :goto_1
    sput v1, Ltop/canyie/pine/Pine;->e:I

    :try_start_0
    sget-object v1, Ltop/canyie/pine/PineConfig;->libLoader:Ltop/canyie/pine/Pine$LibLoader;

    if-eqz v1, :cond_5

    invoke-interface {v1}, Ltop/canyie/pine/Pine$LibLoader;->loadLib()V

    goto :goto_2

    :catch_0
    move-exception v0

    goto :goto_3

    :cond_5
    :goto_2
    sget-boolean v2, Ltop/canyie/pine/PineConfig;->debug:Z

    sget-boolean v3, Ltop/canyie/pine/PineConfig;->debuggable:Z

    sget-boolean v4, Ltop/canyie/pine/PineConfig;->antiChecks:Z

    sget-boolean v5, Ltop/canyie/pine/PineConfig;->disableHiddenApiPolicy:Z

    sget-boolean v6, Ltop/canyie/pine/PineConfig;->disableHiddenApiPolicyForPlatformDomain:Z

    move v1, v0

    invoke-static/range {v1 .. v6}, Ltop/canyie/pine/Pine;->init0(IZZZZZ)V

    invoke-static {}, Ltop/canyie/pine/Pine;->c()V

    sget-boolean v1, Ltop/canyie/pine/PineConfig;->useFastNative:Z

    if-eqz v1, :cond_6

    const/16 v1, 0x15

    if-lt v0, v1, :cond_6

    invoke-static {}, Ltop/canyie/pine/Pine;->enableFastNative()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :cond_6
    return-void

    :goto_3
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "Pine init error"

    invoke-direct {v1, v2, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1

    :cond_7
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "Only supports ART runtime"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_8
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "Unsupported android sdk level "

    invoke-static {v0, v2}, L_COROUTINE/a;->d(ILjava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public static decompile(Ljava/lang/reflect/Member;Z)Z
    .locals 3

    invoke-interface {p0}, Ljava/lang/reflect/Member;->getModifiers()I

    move-result v0

    invoke-interface {p0}, Ljava/lang/reflect/Member;->getDeclaringClass()Ljava/lang/Class;

    move-result-object v1

    instance-of v2, p0, Ljava/lang/reflect/Method;

    if-nez v2, :cond_1

    instance-of v2, p0, Ljava/lang/reflect/Constructor;

    if-eqz v2, :cond_0

    goto :goto_0

    :cond_0
    new-instance p1, Ljava/lang/IllegalArgumentException;

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Only methods and constructors can be decompiled: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_1
    :goto_0
    invoke-static {v0}, Ljava/lang/reflect/Modifier;->isAbstract(I)Z

    move-result v0

    if-nez v0, :cond_3

    invoke-static {v1}, Ljava/lang/reflect/Proxy;->isProxyClass(Ljava/lang/Class;)Z

    move-result v0

    if-eqz v0, :cond_2

    const/4 p0, 0x0

    return p0

    :cond_2
    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    invoke-static {p0, p1}, Ltop/canyie/pine/Pine;->decompile0(Ljava/lang/reflect/Member;Z)Z

    move-result p0

    return p0

    :cond_3
    new-instance p1, Ljava/lang/IllegalArgumentException;

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Cannot decompile abstract methods: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private static native decompile0(Ljava/lang/reflect/Member;Z)Z
.end method

.method public static disableHiddenApiPolicy(ZZ)V
    .locals 1

    sget-boolean v0, Ltop/canyie/pine/Pine;->a:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Ltop/canyie/pine/Pine;->disableHiddenApiPolicy0(ZZ)V

    goto :goto_0

    :cond_0
    sput-boolean p0, Ltop/canyie/pine/PineConfig;->disableHiddenApiPolicy:Z

    sput-boolean p1, Ltop/canyie/pine/PineConfig;->disableHiddenApiPolicyForPlatformDomain:Z

    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    :goto_0
    return-void
.end method

.method private static native disableHiddenApiPolicy0(ZZ)V
.end method

.method public static disableJitInline()Z
    .locals 2

    sget v0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v1, 0x18

    if-ge v0, v1, :cond_0

    const/4 v0, 0x0

    return v0

    :cond_0
    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    invoke-static {}, Ltop/canyie/pine/Pine;->disableJitInline0()Z

    move-result v0

    return v0
.end method

.method private static native disableJitInline0()Z
.end method

.method public static disableProfileSaver()Z
    .locals 2

    sget v0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v1, 0x18

    if-ge v0, v1, :cond_0

    const/4 v0, 0x0

    return v0

    :cond_0
    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    invoke-static {}, Ltop/canyie/pine/Pine;->disableProfileSaver0()Z

    move-result v0

    return v0
.end method

.method private static native disableProfileSaver0()Z
.end method

.method public static e(Ljava/lang/reflect/Method;)V
    .locals 2

    invoke-virtual {p0}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v0

    array-length v0, v0

    const/4 v1, 0x0

    if-lez v0, :cond_0

    move-object v0, v1

    goto :goto_0

    :cond_0
    const/4 v0, 0x1

    new-array v0, v0, [Ljava/lang/Object;

    :goto_0
    :try_start_0
    invoke-virtual {p0, v1, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    new-instance p0, Ljava/lang/RuntimeException;

    const-string v0, "No IllegalArgumentException thrown when resolve static method."

    invoke-direct {p0, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw p0

    :catch_0
    move-exception p0

    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "Unknown exception thrown when resolve static method."

    invoke-direct {v0, v1, p0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v0

    :catch_1
    return-void
.end method

.method private static native enableFastNative()V
.end method

.method public static ensureInitialized()V
    .locals 2

    sget-boolean v0, Ltop/canyie/pine/Pine;->a:Z

    if-eqz v0, :cond_0

    return-void

    :cond_0
    const-class v0, Ltop/canyie/pine/Pine;

    monitor-enter v0

    :try_start_0
    sget-boolean v1, Ltop/canyie/pine/Pine;->a:Z

    if-eqz v1, :cond_1

    monitor-exit v0

    return-void

    :catchall_0
    move-exception v1

    goto :goto_0

    :cond_1
    invoke-static {}, Ltop/canyie/pine/Pine;->d()V

    const/4 v1, 0x1

    sput-boolean v1, Ltop/canyie/pine/Pine;->a:Z

    monitor-exit v0

    return-void

    :goto_0
    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public static getAddress(JLjava/lang/Object;)J
    .locals 0

    if-nez p2, :cond_0

    const-wide/16 p0, 0x0

    return-wide p0

    :cond_0
    invoke-static {p0, p1, p2}, Ltop/canyie/pine/Pine;->getAddress0(JLjava/lang/Object;)J

    move-result-wide p0

    return-wide p0
.end method

.method private static native getAddress0(JLjava/lang/Object;)J
.end method

.method public static native getArgsArm32(II[I[I[F)V
.end method

.method public static native getArgsArm64(JJ[Z[J[J[D)V
.end method

.method public static native getArgsX86(I[II)V
.end method

.method public static native getArtMethod(Ljava/lang/reflect/Member;)J
.end method

.method public static getHookHandler()Ltop/canyie/pine/Pine$HookHandler;
    .locals 1

    sget-object v0, Ltop/canyie/pine/Pine;->f:Ltop/canyie/pine/Pine$HookHandler;

    return-object v0
.end method

.method public static getHookListener()Ltop/canyie/pine/Pine$HookListener;
    .locals 1

    sget-object v0, Ltop/canyie/pine/Pine;->g:Ltop/canyie/pine/Pine$HookListener;

    return-object v0
.end method

.method public static getHookRecord(J)Ltop/canyie/pine/Pine$HookRecord;
    .locals 3

    sget-object v0, Ltop/canyie/pine/Pine;->c:Ljava/util/concurrent/ConcurrentHashMap;

    invoke-static {p0, p1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ltop/canyie/pine/Pine$HookRecord;

    if-eqz v0, :cond_0

    return-object v0

    :cond_0
    new-instance v0, Ljava/lang/AssertionError;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "No HookRecord found for ArtMethod pointer 0x"

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {p0, p1}, Ljava/lang/Long;->toHexString(J)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw v0
.end method

.method public static getObject(JJ)Ljava/lang/Object;
    .locals 2

    const-wide/16 v0, 0x0

    cmp-long v0, p2, v0

    if-nez v0, :cond_0

    const/4 p0, 0x0

    return-object p0

    :cond_0
    invoke-static {p0, p1, p2, p3}, Ltop/canyie/pine/Pine;->getObject0(JJ)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private static native getObject0(JJ)Ljava/lang/Object;
.end method

.method public static handleCall(Ltop/canyie/pine/Pine$HookRecord;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    .locals 7

    const-string v0, "Unexpected exception occurred when calling "

    sget-boolean v1, Ltop/canyie/pine/PineConfig;->debug:Z

    const-string v2, "Pine"

    if-eqz v1, :cond_0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v3, "handleCall for method "

    invoke-direct {v1, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v3, p0, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v2, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    sget-boolean v1, Ltop/canyie/pine/PineConfig;->disableHooks:Z

    if-nez v1, :cond_8

    invoke-virtual {p0}, Ltop/canyie/pine/Pine$HookRecord;->emptyCallbacks()Z

    move-result v1

    if-eqz v1, :cond_1

    goto/16 :goto_3

    :cond_1
    new-instance v1, Ltop/canyie/pine/Pine$CallFrame;

    invoke-direct {v1, p0, p1, p2}, Ltop/canyie/pine/Pine$CallFrame;-><init>(Ltop/canyie/pine/Pine$HookRecord;Ljava/lang/Object;[Ljava/lang/Object;)V

    invoke-virtual {p0}, Ltop/canyie/pine/Pine$HookRecord;->getCallbacks()[Ltop/canyie/pine/callback/MethodHook;

    move-result-object v3

    const/4 p0, 0x0

    :cond_2
    aget-object p1, v3, p0

    :try_start_0
    invoke-virtual {p1, v1}, Ltop/canyie/pine/callback/MethodHook;->beforeCall(Ltop/canyie/pine/Pine$CallFrame;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    iget-boolean p1, v1, Ltop/canyie/pine/Pine$CallFrame;->c:Z

    if-eqz p1, :cond_3

    add-int/lit8 p0, p0, 0x1

    goto :goto_0

    :catchall_0
    move-exception p2

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ".beforeCall()"

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v2, p1, p2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->resetResult()V

    :cond_3
    add-int/lit8 p0, p0, 0x1

    array-length p1, v3

    if-lt p0, p1, :cond_2

    :goto_0
    iget-boolean p1, v1, Ltop/canyie/pine/Pine$CallFrame;->c:Z

    if-nez p1, :cond_4

    :try_start_1
    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->invokeOriginalMethod()Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {v1, p1}, Ltop/canyie/pine/Pine$CallFrame;->setResult(Ljava/lang/Object;)V
    :try_end_1
    .catch Ljava/lang/reflect/InvocationTargetException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_1

    :catch_0
    move-exception p1

    invoke-virtual {p1}, Ljava/lang/reflect/InvocationTargetException;->getTargetException()Ljava/lang/Throwable;

    move-result-object p1

    invoke-virtual {v1, p1}, Ltop/canyie/pine/Pine$CallFrame;->setThrowable(Ljava/lang/Throwable;)V

    :cond_4
    :goto_1
    add-int/lit8 p0, p0, -0x1

    :cond_5
    aget-object p1, v3, p0

    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->getResult()Ljava/lang/Object;

    move-result-object p2

    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->getThrowable()Ljava/lang/Throwable;

    move-result-object v4

    :try_start_2
    invoke-virtual {p1, v1}, Ltop/canyie/pine/callback/MethodHook;->afterCall(Ltop/canyie/pine/Pine$CallFrame;)V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    goto :goto_2

    :catchall_1
    move-exception v5

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v6, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ".afterCall()"

    invoke-virtual {v6, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v2, p1, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    if-nez v4, :cond_6

    invoke-virtual {v1, p2}, Ltop/canyie/pine/Pine$CallFrame;->setResult(Ljava/lang/Object;)V

    goto :goto_2

    :cond_6
    invoke-virtual {v1, v4}, Ltop/canyie/pine/Pine$CallFrame;->setThrowable(Ljava/lang/Throwable;)V

    :goto_2
    add-int/lit8 p0, p0, -0x1

    if-gez p0, :cond_5

    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->hasThrowable()Z

    move-result p0

    if-nez p0, :cond_7

    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->getResult()Ljava/lang/Object;

    move-result-object p0

    return-object p0

    :cond_7
    invoke-virtual {v1}, Ltop/canyie/pine/Pine$CallFrame;->getThrowable()Ljava/lang/Throwable;

    move-result-object p0

    throw p0

    :cond_8
    :goto_3
    :try_start_3
    iget-object v0, p0, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    iget-object p0, p0, Ltop/canyie/pine/Pine$HookRecord;->backup:Ljava/lang/reflect/Method;

    invoke-static {v0, p0, p1, p2}, Ltop/canyie/pine/Pine;->a(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0
    :try_end_3
    .catch Ljava/lang/reflect/InvocationTargetException; {:try_start_3 .. :try_end_3} :catch_1

    return-object p0

    :catch_1
    move-exception p0

    invoke-virtual {p0}, Ljava/lang/reflect/InvocationTargetException;->getTargetException()Ljava/lang/Throwable;

    move-result-object p0

    throw p0
.end method

.method public static hook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook;)Ltop/canyie/pine/callback/MethodHook$Unhook;
    .locals 1

    const/4 v0, 0x1

    .line 1
    invoke-static {p0, p1, v0}, Ltop/canyie/pine/Pine;->hook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook;Z)Ltop/canyie/pine/callback/MethodHook$Unhook;

    move-result-object p0

    return-object p0
.end method

.method public static hook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook;Z)Ltop/canyie/pine/callback/MethodHook$Unhook;
    .locals 8

    .line 2
    sget-boolean v0, Ltop/canyie/pine/PineConfig;->debug:Z

    if-eqz v0, :cond_0

    .line 3
    const-string v0, "Pine"

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Hooking method "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v2, " with callback "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    if-eqz p0, :cond_9

    if-eqz p1, :cond_8

    .line 4
    invoke-interface {p0}, Ljava/lang/reflect/Member;->getModifiers()I

    move-result v5

    .line 5
    instance-of v0, p0, Ljava/lang/reflect/Method;

    const/4 v1, 0x1

    if-eqz v0, :cond_2

    .line 6
    invoke-static {v5}, Ljava/lang/reflect/Modifier;->isAbstract(I)Z

    move-result v0

    if-nez v0, :cond_1

    .line 7
    move-object v0, p0

    check-cast v0, Ljava/lang/reflect/Method;

    invoke-virtual {v0, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    goto :goto_0

    .line 8
    :cond_1
    new-instance p1, Ljava/lang/IllegalArgumentException;

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "Cannot hook abstract methods: "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 9
    :cond_2
    instance-of v0, p0, Ljava/lang/reflect/Constructor;

    if-eqz v0, :cond_7

    .line 10
    invoke-static {v5}, Ljava/lang/reflect/Modifier;->isStatic(I)Z

    move-result v0

    if-nez v0, :cond_6

    .line 11
    move-object v0, p0

    check-cast v0, Ljava/lang/reflect/Constructor;

    invoke-virtual {v0, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    .line 12
    :goto_0
    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    .line 13
    sget-object v0, Ltop/canyie/pine/Pine;->g:Ltop/canyie/pine/Pine$HookListener;

    if-eqz v0, :cond_3

    .line 14
    invoke-interface {v0, p0, p1}, Ltop/canyie/pine/Pine$HookListener;->beforeHook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook;)V

    .line 15
    :cond_3
    invoke-static {p0}, Ltop/canyie/pine/Pine;->getArtMethod(Ljava/lang/reflect/Member;)J

    move-result-wide v2

    .line 16
    sget-object v4, Ltop/canyie/pine/Pine;->d:Ljava/lang/Object;

    monitor-enter v4

    .line 17
    :try_start_0
    sget-object v6, Ltop/canyie/pine/Pine;->c:Ljava/util/concurrent/ConcurrentHashMap;

    invoke-static {v2, v3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/util/concurrent/ConcurrentHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ltop/canyie/pine/Pine$HookRecord;

    if-nez v7, :cond_4

    .line 18
    new-instance v7, Ltop/canyie/pine/Pine$HookRecord;

    invoke-direct {v7, p0, v2, v3}, Ltop/canyie/pine/Pine$HookRecord;-><init>(Ljava/lang/reflect/Member;J)V

    .line 19
    invoke-static {v2, v3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    invoke-virtual {v6, v2, v7}, Ljava/util/concurrent/ConcurrentHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :goto_1
    move v6, v1

    move-object v3, v7

    goto :goto_2

    :catchall_0
    move-exception p0

    goto :goto_3

    :cond_4
    const/4 v1, 0x0

    goto :goto_1

    .line 20
    :goto_2
    monitor-exit v4
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 21
    sget-object v2, Ltop/canyie/pine/Pine;->f:Ltop/canyie/pine/Pine$HookHandler;

    move-object v4, p1

    move v7, p2

    invoke-interface/range {v2 .. v7}, Ltop/canyie/pine/Pine$HookHandler;->handleHook(Ltop/canyie/pine/Pine$HookRecord;Ltop/canyie/pine/callback/MethodHook;IZZ)Ltop/canyie/pine/callback/MethodHook$Unhook;

    move-result-object p1

    if-eqz v0, :cond_5

    .line 22
    invoke-interface {v0, p0, p1}, Ltop/canyie/pine/Pine$HookListener;->afterHook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook$Unhook;)V

    :cond_5
    return-object p1

    .line 23
    :goto_3
    :try_start_1
    monitor-exit v4
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p0

    .line 24
    :cond_6
    new-instance p1, Ljava/lang/IllegalArgumentException;

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "Cannot hook class initializer: "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 25
    :cond_7
    new-instance p1, Ljava/lang/IllegalArgumentException;

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "Only methods and constructors can be hooked: "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 26
    :cond_8
    new-instance p0, Ljava/lang/NullPointerException;

    const-string p1, "callback == null"

    invoke-direct {p0, p1}, Ljava/lang/NullPointerException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 27
    :cond_9
    new-instance p0, Ljava/lang/NullPointerException;

    const-string p1, "method == null"

    invoke-direct {p0, p1}, Ljava/lang/NullPointerException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private static native hook0(JLjava/lang/Class;Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;ZZZ)Ljava/lang/reflect/Method;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(J",
            "Ljava/lang/Class<",
            "*>;",
            "Ljava/lang/reflect/Member;",
            "Ljava/lang/reflect/Method;",
            "ZZZ)",
            "Ljava/lang/reflect/Method;"
        }
    .end annotation
.end method

.method private static native init0(IZZZZZ)V
.end method

.method public static varargs invokeOriginalMethod(Ljava/lang/reflect/Member;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    .locals 3

    if-eqz p0, :cond_7

    instance-of v0, p0, Ljava/lang/reflect/Method;

    const/4 v1, 0x1

    if-eqz v0, :cond_0

    move-object v0, p0

    check-cast v0, Ljava/lang/reflect/Method;

    invoke-virtual {v0, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    goto :goto_0

    :cond_0
    instance-of v0, p0, Ljava/lang/reflect/Constructor;

    if-eqz v0, :cond_6

    move-object v0, p0

    check-cast v0, Ljava/lang/reflect/Constructor;

    invoke-virtual {v0, v1}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    :goto_0
    sget-object v0, Ltop/canyie/pine/Pine;->c:Ljava/util/concurrent/ConcurrentHashMap;

    invoke-static {p0}, Ltop/canyie/pine/Pine;->getArtMethod(Ljava/lang/reflect/Member;)J

    move-result-wide v1

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/concurrent/ConcurrentHashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ltop/canyie/pine/Pine$HookRecord;

    if-nez v0, :cond_4

    sget-boolean v0, Ltop/canyie/pine/PineConfig;->debug:Z

    if-eqz v0, :cond_1

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Attempting to invoke original implementation on a not-hooked method "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v1, ". This is undefined behavior and may have side effect (e.g. if other threads hooked the method before we actually call Method.invoke(), the registered hooks will be triggered)."

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/Throwable;

    const-string v2, "here"

    invoke-direct {v1, v2}, Ljava/lang/Throwable;-><init>(Ljava/lang/String;)V

    const-string v2, "Pine"

    invoke-static {v2, v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_1
    instance-of v0, p0, Ljava/lang/reflect/Constructor;

    if-eqz v0, :cond_3

    if-nez p1, :cond_2

    :try_start_0
    check-cast p0, Ljava/lang/reflect/Constructor;

    invoke-virtual {p0, p2}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0
    :try_end_0
    .catch Ljava/lang/InstantiationException; {:try_start_0 .. :try_end_0} :catch_0

    return-object p0

    :catch_0
    move-exception p0

    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "invalid Constructor"

    invoke-direct {p1, p2, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1

    :cond_2
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "Cannot invoke a not hooked Constructor with a non-null receiver"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_3
    check-cast p0, Ljava/lang/reflect/Method;

    invoke-virtual {p0, p1, p2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0

    :cond_4
    iget-object v1, v0, Ltop/canyie/pine/Pine$HookRecord;->backup:Ljava/lang/reflect/Method;

    if-nez v1, :cond_5

    check-cast p0, Ljava/lang/reflect/Method;

    invoke-static {p0}, Ltop/canyie/pine/Pine;->e(Ljava/lang/reflect/Method;)V

    :cond_5
    iget-object p0, v0, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    iget-object v0, v0, Ltop/canyie/pine/Pine$HookRecord;->backup:Ljava/lang/reflect/Method;

    invoke-static {p0, v0, p1, p2}, Ltop/canyie/pine/Pine;->a(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0

    :cond_6
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "method must be of type Method or Constructor"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_7
    new-instance p0, Ljava/lang/NullPointerException;

    const-string p1, "method == null"

    invoke-direct {p0, p1}, Ljava/lang/NullPointerException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static is64Bit()Z
    .locals 2

    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    sget v0, Ltop/canyie/pine/Pine;->arch:I

    const/4 v1, 0x2

    if-ne v0, v1, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public static isHooked(Ljava/lang/reflect/Member;)Z
    .locals 3

    instance-of v0, p0, Ljava/lang/reflect/Method;

    if-nez v0, :cond_1

    instance-of v0, p0, Ljava/lang/reflect/Constructor;

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    new-instance v0, Ljava/lang/IllegalArgumentException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Only methods and constructors can be hooked: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_1
    :goto_0
    sget-object v0, Ltop/canyie/pine/Pine;->c:Ljava/util/concurrent/ConcurrentHashMap;

    invoke-static {p0}, Ltop/canyie/pine/Pine;->getArtMethod(Ljava/lang/reflect/Member;)J

    move-result-wide v1

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/util/concurrent/ConcurrentHashMap;->containsKey(Ljava/lang/Object;)Z

    move-result p0

    return p0
.end method

.method public static isInitialized()Z
    .locals 1

    sget-boolean v0, Ltop/canyie/pine/Pine;->a:Z

    return v0
.end method

.method public static log(Ljava/lang/String;)V
    .locals 1

    .line 1
    sget-boolean v0, Ltop/canyie/pine/PineConfig;->debug:Z

    if-eqz v0, :cond_0

    .line 2
    const-string v0, "Pine"

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    return-void
.end method

.method public static varargs log(Ljava/lang/String;[Ljava/lang/Object;)V
    .locals 1

    .line 3
    sget-boolean v0, Ltop/canyie/pine/PineConfig;->debug:Z

    if-eqz v0, :cond_0

    .line 4
    invoke-static {p0, p1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    const-string p1, "Pine"

    invoke-static {p1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    return-void
.end method

.method private static native makeClassesVisiblyInitialized(J)V
.end method

.method public static setDebuggable(Z)V
    .locals 2

    sget-boolean v0, Ltop/canyie/pine/Pine;->a:Z

    if-nez v0, :cond_1

    const-class v0, Ltop/canyie/pine/Pine;

    monitor-enter v0

    :try_start_0
    sget-boolean v1, Ltop/canyie/pine/Pine;->a:Z

    if-nez v1, :cond_0

    sput-boolean p0, Ltop/canyie/pine/PineConfig;->debuggable:Z

    invoke-static {}, Ltop/canyie/pine/Pine;->d()V

    const/4 p0, 0x1

    sput-boolean p0, Ltop/canyie/pine/Pine;->a:Z

    monitor-exit v0

    return-void

    :catchall_0
    move-exception p0

    goto :goto_0

    :cond_0
    monitor-exit v0

    goto :goto_1

    :goto_0
    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw p0

    :cond_1
    :goto_1
    sput-boolean p0, Ltop/canyie/pine/PineConfig;->debuggable:Z

    invoke-static {p0}, Ltop/canyie/pine/Pine;->setDebuggable0(Z)V

    return-void
.end method

.method private static native setDebuggable0(Z)V
.end method

.method public static setHookHandler(Ltop/canyie/pine/Pine$HookHandler;)V
    .locals 1

    if-eqz p0, :cond_0

    sput-object p0, Ltop/canyie/pine/Pine;->f:Ltop/canyie/pine/Pine$HookHandler;

    return-void

    :cond_0
    new-instance p0, Ljava/lang/NullPointerException;

    const-string v0, "handler == null"

    invoke-direct {p0, v0}, Ljava/lang/NullPointerException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static setHookListener(Ltop/canyie/pine/Pine$HookListener;)V
    .locals 0

    sput-object p0, Ltop/canyie/pine/Pine;->g:Ltop/canyie/pine/Pine$HookListener;

    return-void
.end method

.method public static setHookMode(I)V
    .locals 2

    if-ltz p0, :cond_2

    const/4 v0, 0x3

    if-gt p0, v0, :cond_2

    if-nez p0, :cond_1

    sget p0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v1, 0x1a

    if-ge p0, v1, :cond_0

    move p0, v0

    goto :goto_0

    :cond_0
    const/4 p0, 0x2

    :cond_1
    :goto_0
    sput p0, Ltop/canyie/pine/Pine;->e:I

    return-void

    :cond_2
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Illegal hookMode "

    invoke-static {p0, v1}, L_COROUTINE/a;->d(ILjava/lang/String;)Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public static setJitCompilationAllowed(Z)V
    .locals 1

    const/4 v0, 0x0

    .line 1
    invoke-static {p0, v0}, Ltop/canyie/pine/Pine;->setJitCompilationAllowed(ZZ)V

    return-void
.end method

.method public static setJitCompilationAllowed(ZZ)V
    .locals 2

    .line 2
    sget v0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v1, 0x18

    if-ge v0, v1, :cond_0

    return-void

    .line 3
    :cond_0
    invoke-static {}, Ltop/canyie/pine/Pine;->ensureInitialized()V

    .line 4
    invoke-static {p0, p1}, Ltop/canyie/pine/Pine;->setJitCompilationAllowed0(ZZ)V

    return-void
.end method

.method private static native setJitCompilationAllowed0(ZZ)V
.end method

.method private static native syncMethodInfo(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;)V
.end method
