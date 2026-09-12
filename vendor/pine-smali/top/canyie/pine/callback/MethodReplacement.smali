.class public abstract Ltop/canyie/pine/callback/MethodReplacement;
.super Ltop/canyie/pine/callback/MethodHook;
.source "SourceFile"


# static fields
.field public static final DO_NOTHING:Ltop/canyie/pine/callback/MethodReplacement;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Ltop/canyie/pine/callback/MethodReplacement$1;

    invoke-direct {v0}, Ltop/canyie/pine/callback/MethodReplacement;-><init>()V

    sput-object v0, Ltop/canyie/pine/callback/MethodReplacement;->DO_NOTHING:Ltop/canyie/pine/callback/MethodReplacement;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ltop/canyie/pine/callback/MethodHook;-><init>()V

    return-void
.end method

.method public static returnConstant(Ljava/lang/Object;)Ltop/canyie/pine/callback/MethodReplacement;
    .locals 1

    new-instance v0, Ltop/canyie/pine/callback/MethodReplacement$2;

    invoke-direct {v0, p0}, Ltop/canyie/pine/callback/MethodReplacement$2;-><init>(Ljava/lang/Object;)V

    return-object v0
.end method


# virtual methods
.method public abstract a(Ltop/canyie/pine/Pine$CallFrame;)Ljava/lang/Object;
.end method

.method public final afterCall(Ltop/canyie/pine/Pine$CallFrame;)V
    .locals 0

    return-void
.end method

.method public final beforeCall(Ltop/canyie/pine/Pine$CallFrame;)V
    .locals 1

    :try_start_0
    invoke-virtual {p0, p1}, Ltop/canyie/pine/callback/MethodReplacement;->a(Ltop/canyie/pine/Pine$CallFrame;)Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {p1, v0}, Ltop/canyie/pine/Pine$CallFrame;->setResult(Ljava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    invoke-virtual {p1, v0}, Ltop/canyie/pine/Pine$CallFrame;->setThrowable(Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method
