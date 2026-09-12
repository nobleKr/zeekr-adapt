.class public final Ltop/canyie/pine/entry/X86Entry;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static final a:[I


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const/4 v0, 0x0

    new-array v0, v0, [I

    sput-object v0, Ltop/canyie/pine/entry/X86Entry;->a:[I

    return-void
.end method

.method private static booleanBridge(III)Z
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Boolean;

    invoke-virtual {p0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0

    return p0
.end method

.method private static byteBridge(III)B
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Byte;

    invoke-virtual {p0}, Ljava/lang/Byte;->byteValue()B

    move-result p0

    return p0
.end method

.method private static charBridge(III)C
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Character;

    invoke-virtual {p0}, Ljava/lang/Character;->charValue()C

    move-result p0

    return p0
.end method

.method private static doubleBridge(III)D
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Double;

    invoke-virtual {p0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide p0

    return-wide p0
.end method

.method private static floatBridge(III)F
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Float;

    invoke-virtual {p0}, Ljava/lang/Float;->floatValue()F

    move-result p0

    return p0
.end method

.method private static handleBridge(III)Ljava/lang/Object;
    .locals 11

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    filled-new-array {v0, v1, v2}, [Ljava/lang/Object;

    move-result-object v0

    const-string v1, "handleBridge: artMethod=%#x extras=%#x ebx=%#x"

    invoke-static {v1, v0}, Ltop/canyie/pine/Pine;->log(Ljava/lang/String;[Ljava/lang/Object;)V

    int-to-long v0, p0

    invoke-static {v0, v1}, Ltop/canyie/pine/Pine;->getHookRecord(J)Ltop/canyie/pine/Pine$HookRecord;

    move-result-object p0

    iget-boolean v0, p0, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    const/4 v1, 0x1

    xor-int/2addr v0, v1

    iget-object v2, p0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    array-length v3, v2

    const/4 v4, 0x0

    move v5, v4

    :goto_0
    if-ge v5, v3, :cond_2

    aget-object v6, v2, v5

    sget-object v7, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    if-eq v6, v7, :cond_1

    sget-object v7, Ljava/lang/Double;->TYPE:Ljava/lang/Class;

    if-ne v6, v7, :cond_0

    goto :goto_1

    :cond_0
    move v6, v1

    goto :goto_2

    :cond_1
    :goto_1
    const/4 v6, 0x2

    :goto_2
    add-int/2addr v0, v6

    add-int/lit8 v5, v5, 0x1

    goto :goto_0

    :cond_2
    if-eqz v0, :cond_3

    new-array v0, v0, [I

    goto :goto_3

    :cond_3
    sget-object v0, Ltop/canyie/pine/entry/X86Entry;->a:[I

    :goto_3
    invoke-static {p1, v0, p2}, Ltop/canyie/pine/Pine;->getArgsX86(I[II)V

    invoke-static {}, Ltop/canyie/pine/Pine;->currentArtThread0()J

    move-result-wide p1

    iget-boolean v2, p0, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-eqz v2, :cond_4

    const/4 v2, 0x0

    move v3, v4

    goto :goto_4

    :cond_4
    aget v2, v0, v4

    int-to-long v2, v2

    invoke-static {p1, p2, v2, v3}, Ltop/canyie/pine/Pine;->getObject(JJ)Ljava/lang/Object;

    move-result-object v2

    move v3, v1

    :goto_4
    iget v5, p0, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-lez v5, :cond_f

    new-array v5, v5, [Ljava/lang/Object;

    move v6, v4

    :goto_5
    iget v7, p0, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-ge v6, v7, :cond_10

    iget-object v7, p0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    aget-object v7, v7, v6

    invoke-virtual {v7}, Ljava/lang/Class;->isPrimitive()Z

    move-result v8

    if-eqz v8, :cond_e

    sget-object v8, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_5

    aget v7, v0, v3

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    goto/16 :goto_8

    :cond_5
    sget-object v8, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_6

    add-int/lit8 v7, v3, 0x1

    aget v3, v0, v3

    aget v8, v0, v7

    invoke-static {v3, v8}, Ltop/canyie/pine/utils/Primitives;->ints2Long(II)J

    move-result-wide v8

    invoke-static {v8, v9}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    :goto_6
    move v10, v7

    move-object v7, v3

    move v3, v10

    goto/16 :goto_8

    :cond_6
    sget-object v8, Ljava/lang/Double;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_7

    add-int/lit8 v7, v3, 0x1

    aget v3, v0, v3

    aget v8, v0, v7

    invoke-static {v3, v8}, Ltop/canyie/pine/utils/Primitives;->ints2Double(II)D

    move-result-wide v8

    invoke-static {v8, v9}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v3

    goto :goto_6

    :cond_7
    sget-object v8, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_8

    aget v7, v0, v3

    invoke-static {v7}, Ljava/lang/Float;->intBitsToFloat(I)F

    move-result v7

    invoke-static {v7}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v7

    goto :goto_8

    :cond_8
    sget-object v8, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_a

    aget v7, v0, v3

    if-eqz v7, :cond_9

    move v7, v1

    goto :goto_7

    :cond_9
    move v7, v4

    :goto_7
    invoke-static {v7}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v7

    goto :goto_8

    :cond_a
    sget-object v8, Ljava/lang/Short;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_b

    aget v7, v0, v3

    int-to-short v7, v7

    invoke-static {v7}, Ljava/lang/Short;->valueOf(S)Ljava/lang/Short;

    move-result-object v7

    goto :goto_8

    :cond_b
    sget-object v8, Ljava/lang/Character;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_c

    aget v7, v0, v3

    int-to-char v7, v7

    invoke-static {v7}, Ljava/lang/Character;->valueOf(C)Ljava/lang/Character;

    move-result-object v7

    goto :goto_8

    :cond_c
    sget-object v8, Ljava/lang/Byte;->TYPE:Ljava/lang/Class;

    if-ne v7, v8, :cond_d

    aget v7, v0, v3

    int-to-byte v7, v7

    invoke-static {v7}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v7

    goto :goto_8

    :cond_d
    new-instance p0, Ljava/lang/AssertionError;

    new-instance p1, Ljava/lang/StringBuilder;

    const-string p2, "Unknown primitive type: "

    invoke-direct {p1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw p0

    :cond_e
    aget v7, v0, v3

    int-to-long v7, v7

    invoke-static {p1, p2, v7, v8}, Ltop/canyie/pine/Pine;->getObject(JJ)Ljava/lang/Object;

    move-result-object v7

    :goto_8
    aput-object v7, v5, v6

    add-int/2addr v3, v1

    add-int/lit8 v6, v6, 0x1

    goto/16 :goto_5

    :cond_f
    sget-object v5, Ltop/canyie/pine/Pine;->EMPTY_OBJECT_ARRAY:[Ljava/lang/Object;

    :cond_10
    invoke-static {p0, v2, v5}, Ltop/canyie/pine/Pine;->handleCall(Ltop/canyie/pine/Pine$HookRecord;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private static intBridge(III)I
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result p0

    return p0
.end method

.method private static longBridge(III)J
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Long;

    invoke-virtual {p0}, Ljava/lang/Long;->longValue()J

    move-result-wide p0

    return-wide p0
.end method

.method private static objectBridge(III)Ljava/lang/Object;
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private static shortBridge(III)S
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Short;

    invoke-virtual {p0}, Ljava/lang/Short;->shortValue()S

    move-result p0

    return p0
.end method

.method private static voidBridge(III)V
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/X86Entry;->handleBridge(III)Ljava/lang/Object;

    return-void
.end method
