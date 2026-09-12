.class public Ltop/canyie/pine/Pine$CallFrame;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ltop/canyie/pine/Pine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "CallFrame"
.end annotation


# instance fields
.field public a:Ljava/lang/Object;

.field public args:[Ljava/lang/Object;

.field public b:Ljava/lang/Throwable;

.field public c:Z

.field public final d:Ltop/canyie/pine/Pine$HookRecord;

.field public final method:Ljava/lang/reflect/Member;

.field public thisObject:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Ltop/canyie/pine/Pine$HookRecord;Ljava/lang/Object;[Ljava/lang/Object;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->d:Ltop/canyie/pine/Pine$HookRecord;

    iget-object p1, p1, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->method:Ljava/lang/reflect/Member;

    iput-object p2, p0, Ltop/canyie/pine/Pine$CallFrame;->thisObject:Ljava/lang/Object;

    iput-object p3, p0, Ltop/canyie/pine/Pine$CallFrame;->args:[Ljava/lang/Object;

    return-void
.end method


# virtual methods
.method public getResult()Ljava/lang/Object;
    .locals 1

    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->a:Ljava/lang/Object;

    return-object v0
.end method

.method public getResultOrThrowable()Ljava/lang/Object;
    .locals 1

    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    if-nez v0, :cond_0

    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->a:Ljava/lang/Object;

    return-object v0

    :cond_0
    throw v0
.end method

.method public getThrowable()Ljava/lang/Throwable;
    .locals 1

    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    return-object v0
.end method

.method public hasThrowable()Z
    .locals 1

    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public invokeOriginalMethod()Ljava/lang/Object;
    .locals 4

    .line 1
    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->d:Ltop/canyie/pine/Pine$HookRecord;

    iget-object v1, v0, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    iget-object v0, v0, Ltop/canyie/pine/Pine$HookRecord;->backup:Ljava/lang/reflect/Method;

    iget-object v2, p0, Ltop/canyie/pine/Pine$CallFrame;->thisObject:Ljava/lang/Object;

    iget-object v3, p0, Ltop/canyie/pine/Pine$CallFrame;->args:[Ljava/lang/Object;

    invoke-static {v1, v0, v2, v3}, Ltop/canyie/pine/Pine;->a(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method public varargs invokeOriginalMethod(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    .locals 2

    .line 2
    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->d:Ltop/canyie/pine/Pine$HookRecord;

    iget-object v1, v0, Ltop/canyie/pine/Pine$HookRecord;->target:Ljava/lang/reflect/Member;

    iget-object v0, v0, Ltop/canyie/pine/Pine$HookRecord;->backup:Ljava/lang/reflect/Method;

    invoke-static {v1, v0, p1, p2}, Ltop/canyie/pine/Pine;->a(Ljava/lang/reflect/Member;Ljava/lang/reflect/Method;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public resetResult()V
    .locals 1

    const/4 v0, 0x0

    iput-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->a:Ljava/lang/Object;

    iput-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    const/4 v0, 0x0

    iput-boolean v0, p0, Ltop/canyie/pine/Pine$CallFrame;->c:Z

    return-void
.end method

.method public setResult(Ljava/lang/Object;)V
    .locals 0

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->a:Ljava/lang/Object;

    const/4 p1, 0x0

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    const/4 p1, 0x1

    iput-boolean p1, p0, Ltop/canyie/pine/Pine$CallFrame;->c:Z

    return-void
.end method

.method public setResultIfNoException(Ljava/lang/Object;)V
    .locals 1

    iget-object v0, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    if-nez v0, :cond_0

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->a:Ljava/lang/Object;

    const/4 p1, 0x1

    iput-boolean p1, p0, Ltop/canyie/pine/Pine$CallFrame;->c:Z

    :cond_0
    return-void
.end method

.method public setThrowable(Ljava/lang/Throwable;)V
    .locals 0

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->b:Ljava/lang/Throwable;

    const/4 p1, 0x0

    iput-object p1, p0, Ltop/canyie/pine/Pine$CallFrame;->a:Ljava/lang/Object;

    const/4 p1, 0x1

    iput-boolean p1, p0, Ltop/canyie/pine/Pine$CallFrame;->c:Z

    return-void
.end method
