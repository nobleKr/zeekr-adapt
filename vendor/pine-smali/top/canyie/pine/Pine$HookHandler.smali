.class public interface abstract Ltop/canyie/pine/Pine$HookHandler;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ltop/canyie/pine/Pine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "HookHandler"
.end annotation


# virtual methods
.method public abstract handleHook(Ltop/canyie/pine/Pine$HookRecord;Ltop/canyie/pine/callback/MethodHook;IZZ)Ltop/canyie/pine/callback/MethodHook$Unhook;
.end method

.method public abstract handleUnhook(Ltop/canyie/pine/Pine$HookRecord;Ltop/canyie/pine/callback/MethodHook;)V
.end method
