.class Ltop/canyie/pine/Pine$1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ltop/canyie/pine/Pine$HookHandler;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ltop/canyie/pine/Pine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = null
.end annotation


# virtual methods
.method public final handleHook(Ltop/canyie/pine/Pine$HookRecord;Ltop/canyie/pine/callback/MethodHook;IZZ)Ltop/canyie/pine/callback/MethodHook$Unhook;
    .locals 0

    if-eqz p4, :cond_0

    invoke-static {p1, p3, p5}, Ltop/canyie/pine/Pine;->b(Ltop/canyie/pine/Pine$HookRecord;IZ)V

    :cond_0
    if-nez p2, :cond_1

    const/4 p1, 0x0

    return-object p1

    :cond_1
    invoke-virtual {p1, p2}, Ltop/canyie/pine/Pine$HookRecord;->addCallback(Ltop/canyie/pine/callback/MethodHook;)V

    new-instance p3, Ltop/canyie/pine/callback/MethodHook$Unhook;

    invoke-direct {p3, p2, p1}, Ltop/canyie/pine/callback/MethodHook$Unhook;-><init>(Ltop/canyie/pine/callback/MethodHook;Ltop/canyie/pine/Pine$HookRecord;)V

    return-object p3
.end method

.method public final handleUnhook(Ltop/canyie/pine/Pine$HookRecord;Ltop/canyie/pine/callback/MethodHook;)V
    .locals 0

    invoke-virtual {p1, p2}, Ltop/canyie/pine/Pine$HookRecord;->removeCallback(Ltop/canyie/pine/callback/MethodHook;)V

    return-void
.end method
