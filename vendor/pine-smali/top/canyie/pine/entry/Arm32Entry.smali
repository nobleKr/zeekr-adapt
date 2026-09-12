.class public final Ltop/canyie/pine/entry/Arm32Entry;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;
    }
.end annotation


# static fields
.field public static final a:[I

.field public static final b:[F

.field public static final c:Z

.field public static final d:Z


# direct methods
.method static constructor <clinit>()V
    .locals 4

    const/4 v0, 0x0

    new-array v1, v0, [I

    sput-object v1, Ltop/canyie/pine/entry/Arm32Entry;->a:[I

    new-array v1, v0, [F

    sput-object v1, Ltop/canyie/pine/entry/Arm32Entry;->b:[F

    sget v1, Ltop/canyie/pine/PineConfig;->sdkLevel:I

    const/16 v2, 0x17

    const/4 v3, 0x1

    if-lt v1, v2, :cond_0

    move v2, v3

    goto :goto_0

    :cond_0
    move v2, v0

    :goto_0
    sput-boolean v2, Ltop/canyie/pine/entry/Arm32Entry;->c:Z

    const/16 v2, 0x1f

    if-lt v1, v2, :cond_1

    move v0, v3

    :cond_1
    sput-boolean v0, Ltop/canyie/pine/entry/Arm32Entry;->d:Z

    return-void
.end method

.method private static booleanBridge(III)Z
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Boolean;

    invoke-virtual {p0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0

    return p0
.end method

.method private static byteBridge(III)B
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Byte;

    invoke-virtual {p0}, Ljava/lang/Byte;->byteValue()B

    move-result p0

    return p0
.end method

.method private static charBridge(III)C
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Character;

    invoke-virtual {p0}, Ljava/lang/Character;->charValue()C

    move-result p0

    return p0
.end method

.method private static doubleBridge(III)D
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Double;

    invoke-virtual {p0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide p0

    return-wide p0
.end method

.method private static floatBridge(III)F
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Float;

    invoke-virtual {p0}, Ljava/lang/Float;->floatValue()F

    move-result p0

    return p0
.end method

.method private static handleBridge(III)Ljava/lang/Object;
    .locals 19

    move/from16 v0, p1

    int-to-long v1, v0

    invoke-static {v1, v2}, Ltop/canyie/pine/Pine;->cloneExtras(J)J

    move-result-wide v1

    long-to-int v1, v1

    invoke-static/range {p0 .. p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-static/range {p1 .. p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-static/range {p2 .. p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    filled-new-array {v2, v0, v3, v4}, [Ljava/lang/Object;

    move-result-object v0

    const-string v2, "handleBridge: artMethod=%#x originExtras=%#x extras=%#x sp=%#x"

    invoke-static {v2, v0}, Ltop/canyie/pine/Pine;->log(Ljava/lang/String;[Ljava/lang/Object;)V

    move/from16 v0, p0

    int-to-long v2, v0

    invoke-static {v2, v3}, Ltop/canyie/pine/Pine;->getHookRecord(J)Ltop/canyie/pine/Pine$HookRecord;

    move-result-object v0

    iget-object v2, v0, Ltop/canyie/pine/Pine$HookRecord;->paramTypesCache:Ljava/lang/Object;

    const/4 v3, 0x3

    const/4 v4, 0x2

    const/4 v5, 0x0

    const/4 v6, 0x1

    if-nez v2, :cond_7

    iget-boolean v2, v0, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    xor-int/2addr v2, v6

    iget-object v7, v0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    array-length v8, v7

    move v9, v2

    move v10, v5

    move v11, v10

    move v12, v11

    :goto_0
    if-ge v10, v8, :cond_6

    aget-object v13, v7, v10

    sget-object v14, Ljava/lang/Double;->TYPE:Ljava/lang/Class;

    if-ne v13, v14, :cond_0

    add-int/lit8 v11, v11, 0x1

    add-int/lit8 v9, v9, 0x1

    goto :goto_1

    :cond_0
    sget-object v14, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    if-ne v13, v14, :cond_1

    add-int/lit8 v12, v12, 0x1

    goto :goto_1

    :cond_1
    sget-object v14, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    if-ne v13, v14, :cond_4

    if-nez v2, :cond_2

    add-int/lit8 v2, v2, 0x1

    :cond_2
    if-ge v2, v3, :cond_3

    add-int/lit8 v2, v2, 0x1

    :cond_3
    add-int/lit8 v9, v9, 0x1

    :cond_4
    if-ge v2, v3, :cond_5

    add-int/lit8 v2, v2, 0x1

    :cond_5
    :goto_1
    add-int/2addr v9, v6

    add-int/lit8 v10, v10, 0x1

    goto :goto_0

    :cond_6
    mul-int/2addr v11, v4

    add-int/2addr v11, v12

    new-instance v7, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;

    invoke-direct {v7}, Ljava/lang/Object;-><init>()V

    iput v2, v7, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;->a:I

    iput v9, v7, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;->b:I

    iput v11, v7, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;->c:I

    iput-object v7, v0, Ltop/canyie/pine/Pine$HookRecord;->paramTypesCache:Ljava/lang/Object;

    goto :goto_2

    :cond_7
    iget-object v2, v0, Ltop/canyie/pine/Pine$HookRecord;->paramTypesCache:Ljava/lang/Object;

    check-cast v2, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;

    iget v7, v2, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;->a:I

    iget v9, v2, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;->b:I

    iget v11, v2, Ltop/canyie/pine/entry/Arm32Entry$ParamTypesCache;->c:I

    move v2, v7

    :goto_2
    sget-object v7, Ltop/canyie/pine/entry/Arm32Entry;->b:[F

    sget-boolean v8, Ltop/canyie/pine/entry/Arm32Entry;->c:Z

    if-eqz v8, :cond_8

    if-eqz v11, :cond_9

    invoke-static {v11}, Ltop/canyie/pine/utils/Primitives;->evenUp(I)I

    move-result v7

    const/16 v8, 0x10

    invoke-static {v7, v8}, Ljava/lang/Math;->min(II)I

    move-result v7

    new-array v7, v7, [F

    goto :goto_3

    :cond_8
    add-int/2addr v2, v11

    invoke-static {v2, v3}, Ljava/lang/Math;->min(II)I

    move-result v2

    :cond_9
    :goto_3
    sget-object v8, Ltop/canyie/pine/entry/Arm32Entry;->a:[I

    if-eqz v2, :cond_a

    new-array v2, v2, [I

    goto :goto_4

    :cond_a
    move-object v2, v8

    :goto_4
    if-eqz v9, :cond_b

    new-array v8, v9, [I

    :cond_b
    move/from16 v9, p2

    invoke-static {v1, v9, v2, v8, v7}, Ltop/canyie/pine/Pine;->getArgsArm32(II[I[I[F)V

    new-instance v1, Ltop/canyie/pine/utils/ThreeTuple;

    invoke-direct {v1, v2, v8, v7}, Ltop/canyie/pine/utils/ThreeTuple;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V

    iget-object v2, v1, Ltop/canyie/pine/utils/ThreeTuple;->a:Ljava/lang/Object;

    check-cast v2, [I

    iget-object v7, v1, Ltop/canyie/pine/utils/ThreeTuple;->b:Ljava/lang/Object;

    check-cast v7, [I

    iget-object v1, v1, Ltop/canyie/pine/utils/ThreeTuple;->c:Ljava/lang/Object;

    check-cast v1, [F

    invoke-static {}, Ltop/canyie/pine/Pine;->currentArtThread0()J

    move-result-wide v8

    iget-boolean v10, v0, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-eqz v10, :cond_c

    const/4 v10, 0x0

    move v11, v5

    :goto_5
    move v12, v11

    goto :goto_6

    :cond_c
    aget v10, v2, v5

    int-to-long v10, v10

    invoke-static {v8, v9, v10, v11}, Ltop/canyie/pine/Pine;->getObject(JJ)Ljava/lang/Object;

    move-result-object v10

    move v11, v6

    goto :goto_5

    :goto_6
    iget v13, v0, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-lez v13, :cond_22

    new-array v13, v13, [Ljava/lang/Object;

    move/from16 p0, v5

    move/from16 v14, p0

    move v15, v14

    :goto_7
    iget v3, v0, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-ge v14, v3, :cond_23

    iget-object v3, v0, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    aget-object v3, v3, v14

    sget-object v5, Ljava/lang/Double;->TYPE:Ljava/lang/Class;

    if-ne v3, v5, :cond_10

    invoke-static/range {p0 .. p0}, Ltop/canyie/pine/utils/Primitives;->evenUp(I)I

    move-result v3

    invoke-static {v15, v3}, Ljava/lang/Math;->max(II)I

    move-result v15

    array-length v3, v1

    if-ge v15, v3, :cond_d

    add-int/lit8 v3, v15, 0x1

    aget v5, v1, v15

    add-int/lit8 v15, v15, 0x2

    aget v3, v1, v3

    invoke-static {v5, v3}, Ltop/canyie/pine/utils/Primitives;->floats2Double(FF)D

    move-result-wide v16

    invoke-static/range {v16 .. v17}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v3

    add-int/lit8 v12, v12, 0x1

    move/from16 v5, p0

    :goto_8
    move-object/from16 p2, v2

    :goto_9
    move-object/from16 v18, v3

    move-object v3, v1

    move-object/from16 v1, v18

    goto/16 :goto_13

    :cond_d
    array-length v3, v2

    if-ge v11, v3, :cond_e

    sget-boolean v3, Ltop/canyie/pine/entry/Arm32Entry;->c:Z

    if-nez v3, :cond_e

    add-int/lit8 v3, v11, 0x1

    aget v5, v2, v11

    move v11, v3

    goto :goto_a

    :cond_e
    aget v5, v7, v12

    :goto_a
    add-int/lit8 v12, v12, 0x1

    array-length v3, v2

    if-ge v11, v3, :cond_f

    sget-boolean v3, Ltop/canyie/pine/entry/Arm32Entry;->c:Z

    if-nez v3, :cond_f

    add-int/lit8 v3, v11, 0x1

    aget v11, v2, v11

    goto :goto_b

    :cond_f
    aget v3, v7, v12

    move/from16 v18, v11

    move v11, v3

    move/from16 v3, v18

    :goto_b
    invoke-static {v5, v11}, Ltop/canyie/pine/utils/Primitives;->ints2Double(II)D

    move-result-wide v16

    invoke-static/range {v16 .. v17}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v5

    move-object/from16 p2, v2

    move v11, v3

    move-object v3, v1

    move-object v1, v5

    move/from16 v5, p0

    goto/16 :goto_13

    :cond_10
    sget-object v5, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    if-ne v3, v5, :cond_14

    move/from16 v5, p0

    rem-int/lit8 v3, v5, 0x2

    if-nez v3, :cond_11

    invoke-static {v15, v5}, Ljava/lang/Math;->max(II)I

    move-result v3

    goto :goto_c

    :cond_11
    move v3, v5

    :goto_c
    array-length v5, v1

    if-ge v3, v5, :cond_12

    add-int/lit8 v5, v3, 0x1

    aget v3, v1, v3

    invoke-static {v3}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v3

    goto :goto_8

    :cond_12
    array-length v5, v2

    if-ge v11, v5, :cond_13

    sget-boolean v5, Ltop/canyie/pine/entry/Arm32Entry;->c:Z

    if-nez v5, :cond_13

    add-int/lit8 v5, v11, 0x1

    aget v11, v2, v11

    goto :goto_d

    :cond_13
    aget v5, v7, v12

    move/from16 v18, v11

    move v11, v5

    move/from16 v5, v18

    :goto_d
    invoke-static {v11}, Ljava/lang/Float;->intBitsToFloat(I)F

    move-result v11

    invoke-static {v11}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v11

    move-object/from16 p2, v2

    move/from16 v18, v3

    move-object v3, v1

    move-object v1, v11

    move v11, v5

    move/from16 v5, v18

    goto/16 :goto_13

    :cond_14
    move/from16 v5, p0

    sget-object v4, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    if-ne v3, v4, :cond_19

    if-nez v11, :cond_15

    iget-boolean v3, v0, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-eqz v3, :cond_15

    sget-boolean v3, Ltop/canyie/pine/entry/Arm32Entry;->c:Z

    if-eqz v3, :cond_15

    aget v3, v2, v6

    const/4 v4, 0x2

    aget v11, v2, v4

    invoke-static {v3, v11}, Ltop/canyie/pine/utils/Primitives;->ints2Long(II)J

    move-result-wide v16

    invoke-static/range {v16 .. v17}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    aput-object v3, v13, v14

    add-int/lit8 v12, v12, 0x2

    move-object v3, v1

    move-object/from16 p2, v2

    move v1, v6

    const/4 v11, 0x3

    goto/16 :goto_14

    :cond_15
    const/4 v4, 0x2

    if-ne v11, v4, :cond_16

    sget-boolean v3, Ltop/canyie/pine/entry/Arm32Entry;->d:Z

    if-eqz v3, :cond_16

    const/4 v11, 0x3

    :cond_16
    array-length v3, v2

    if-ge v11, v3, :cond_17

    add-int/lit8 v3, v11, 0x1

    aget v11, v2, v11

    move/from16 v18, v11

    move v11, v3

    move/from16 v3, v18

    goto :goto_e

    :cond_17
    aget v3, v7, v12

    :goto_e
    add-int/lit8 v12, v12, 0x1

    array-length v4, v2

    if-ge v11, v4, :cond_18

    add-int/lit8 v4, v11, 0x1

    aget v11, v2, v11

    goto :goto_f

    :cond_18
    aget v4, v7, v12

    move/from16 v18, v11

    move v11, v4

    move/from16 v4, v18

    :goto_f
    invoke-static {v3, v11}, Ltop/canyie/pine/utils/Primitives;->ints2Long(II)J

    move-result-wide v16

    invoke-static/range {v16 .. v17}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    :goto_10
    move-object/from16 p2, v2

    move v11, v4

    goto/16 :goto_9

    :cond_19
    array-length v4, v2

    if-ge v11, v4, :cond_1a

    add-int/lit8 v4, v11, 0x1

    aget v11, v2, v11

    goto :goto_11

    :cond_1a
    aget v4, v7, v12

    move/from16 v18, v11

    move v11, v4

    move/from16 v4, v18

    :goto_11
    invoke-virtual {v3}, Ljava/lang/Class;->isPrimitive()Z

    move-result v16

    if-eqz v16, :cond_21

    sget-object v6, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    if-ne v3, v6, :cond_1b

    invoke-static {v11}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    goto :goto_10

    :cond_1b
    sget-object v6, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    if-ne v3, v6, :cond_1d

    if-eqz v11, :cond_1c

    const/4 v3, 0x1

    goto :goto_12

    :cond_1c
    const/4 v3, 0x0

    :goto_12
    invoke-static {v3}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v3

    goto :goto_10

    :cond_1d
    sget-object v6, Ljava/lang/Short;->TYPE:Ljava/lang/Class;

    if-ne v3, v6, :cond_1e

    int-to-short v3, v11

    invoke-static {v3}, Ljava/lang/Short;->valueOf(S)Ljava/lang/Short;

    move-result-object v3

    goto :goto_10

    :cond_1e
    sget-object v6, Ljava/lang/Character;->TYPE:Ljava/lang/Class;

    if-ne v3, v6, :cond_1f

    int-to-char v3, v11

    invoke-static {v3}, Ljava/lang/Character;->valueOf(C)Ljava/lang/Character;

    move-result-object v3

    goto :goto_10

    :cond_1f
    sget-object v6, Ljava/lang/Byte;->TYPE:Ljava/lang/Class;

    if-ne v3, v6, :cond_20

    int-to-byte v3, v11

    invoke-static {v3}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v3

    goto :goto_10

    :cond_20
    new-instance v0, Ljava/lang/AssertionError;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Unknown primitive type: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw v0

    :cond_21
    move-object v3, v1

    move-object/from16 p2, v2

    int-to-long v1, v11

    invoke-static {v8, v9, v1, v2}, Ltop/canyie/pine/Pine;->getObject(JJ)Ljava/lang/Object;

    move-result-object v1

    move v11, v4

    :goto_13
    aput-object v1, v13, v14

    const/4 v1, 0x1

    add-int/2addr v12, v1

    :goto_14
    add-int/lit8 v14, v14, 0x1

    move-object/from16 v2, p2

    move v6, v1

    move-object v1, v3

    move/from16 p0, v5

    const/4 v4, 0x2

    const/4 v5, 0x0

    goto/16 :goto_7

    :cond_22
    sget-object v13, Ltop/canyie/pine/Pine;->EMPTY_OBJECT_ARRAY:[Ljava/lang/Object;

    :cond_23
    invoke-static {v0, v10, v13}, Ltop/canyie/pine/Pine;->handleCall(Ltop/canyie/pine/Pine$HookRecord;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method private static intBridge(III)I
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result p0

    return p0
.end method

.method private static longBridge(III)J
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Long;

    invoke-virtual {p0}, Ljava/lang/Long;->longValue()J

    move-result-wide p0

    return-wide p0
.end method

.method private static objectBridge(III)Ljava/lang/Object;
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private static shortBridge(III)S
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Short;

    invoke-virtual {p0}, Ljava/lang/Short;->shortValue()S

    move-result p0

    return p0
.end method

.method private static voidBridge(III)V
    .locals 0

    invoke-static {p0, p1, p2}, Ltop/canyie/pine/entry/Arm32Entry;->handleBridge(III)Ljava/lang/Object;

    return-void
.end method
