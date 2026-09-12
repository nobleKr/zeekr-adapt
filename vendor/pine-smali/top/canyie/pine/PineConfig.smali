.class public final Ltop/canyie/pine/PineConfig;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static antiChecks:Z = false

.field public static debug:Z = true

.field public static debuggable:Z = false

.field public static disableHiddenApiPolicy:Z = true

.field public static disableHiddenApiPolicyForPlatformDomain:Z = true

.field public static disableHooks:Z

.field public static libLoader:Ltop/canyie/pine/Pine$LibLoader;

.field public static sdkLevel:I

.field public static useFastNative:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Ltop/canyie/pine/PineConfig$1;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Ltop/canyie/pine/PineConfig;->libLoader:Ltop/canyie/pine/Pine$LibLoader;

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    sput v0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v1, 0x1e

    if-ne v0, v1, :cond_0

    sget v0, Landroid/os/Build$VERSION;->PREVIEW_SDK_INT:I

    if-lez v0, :cond_0

    const/16 v0, 0x1f

    sput v0, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    :cond_0
    return-void
.end method
