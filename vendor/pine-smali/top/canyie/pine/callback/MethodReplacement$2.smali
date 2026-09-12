.class Ltop/canyie/pine/callback/MethodReplacement$2;
.super Ltop/canyie/pine/callback/MethodReplacement;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Ltop/canyie/pine/callback/MethodReplacement;->returnConstant(Ljava/lang/Object;)Ltop/canyie/pine/callback/MethodReplacement;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = null
.end annotation


# instance fields
.field public final synthetic a:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Ljava/lang/Object;)V
    .locals 0

    iput-object p1, p0, Ltop/canyie/pine/callback/MethodReplacement$2;->a:Ljava/lang/Object;

    invoke-direct {p0}, Ltop/canyie/pine/callback/MethodReplacement;-><init>()V

    return-void
.end method


# virtual methods
.method public final a(Ltop/canyie/pine/Pine$CallFrame;)Ljava/lang/Object;
    .locals 0

    iget-object p1, p0, Ltop/canyie/pine/callback/MethodReplacement$2;->a:Ljava/lang/Object;

    return-object p1
.end method
