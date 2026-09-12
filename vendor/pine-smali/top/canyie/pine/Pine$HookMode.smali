.class public interface abstract Ltop/canyie/pine/Pine$HookMode;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ltop/canyie/pine/Pine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "HookMode"
.end annotation


# static fields
.field public static final AUTO:I = 0x0

.field public static final INLINE:I = 0x1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation
.end field

.field public static final INLINE_WITHOUT_JIT:I = 0x3

.field public static final REPLACEMENT:I = 0x2
