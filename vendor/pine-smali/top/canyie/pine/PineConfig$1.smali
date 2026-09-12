.class Ltop/canyie/pine/PineConfig$1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ltop/canyie/pine/Pine$LibLoader;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ltop/canyie/pine/PineConfig;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1
    name = null
.end annotation


# virtual methods
.method public final loadLib()V
    .locals 1

    const-string v0, "pine"

    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V

    return-void
.end method
