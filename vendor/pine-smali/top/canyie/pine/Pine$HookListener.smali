.class public interface abstract Ltop/canyie/pine/Pine$HookListener;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ltop/canyie/pine/Pine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "HookListener"
.end annotation


# virtual methods
.method public abstract afterHook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook$Unhook;)V
.end method

.method public abstract beforeHook(Ljava/lang/reflect/Member;Ltop/canyie/pine/callback/MethodHook;)V
.end method
