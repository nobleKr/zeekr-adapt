.class public final Ltop/canyie/pine/entry/Arm64Entry;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;
    }
.end annotation


# static fields
.field public static final a:[Z

.field public static final b:[J

.field public static final c:[D


# direct methods
.method static constructor <clinit>()V
    .locals 2

    const/4 v0, 0x0

    new-array v1, v0, [Z

    sput-object v1, Ltop/canyie/pine/entry/Arm64Entry;->a:[Z

    new-array v1, v0, [J

    sput-object v1, Ltop/canyie/pine/entry/Arm64Entry;->b:[J

    new-array v0, v0, [D

    sput-object v0, Ltop/canyie/pine/entry/Arm64Entry;->c:[D

    return-void
.end method

.method public static booleanBridge(JJJJJJJ)Z
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Boolean;

    invoke-virtual {p0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0

    return p0
.end method

.method public static byteBridge(JJJJJJJ)B
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Byte;

    invoke-virtual {p0}, Ljava/lang/Byte;->byteValue()B

    move-result p0

    return p0
.end method

.method public static charBridge(JJJJJJJ)C
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Character;

    invoke-virtual {p0}, Ljava/lang/Character;->charValue()C

    move-result p0

    return p0
.end method

.method public static doubleBridge(JJJJJJJ)D
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Double;

    invoke-virtual {p0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide p0

    return-wide p0
.end method

.method public static floatBridge(JJJJJJJ)F
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Float;

    invoke-virtual {p0}, Ljava/lang/Float;->floatValue()F

    move-result p0

    return p0
.end method

.method private static handleBridge(JJJJJJJ)Ljava/lang/Object;
    .locals 21

    invoke-static/range {p2 .. p3}, Ltop/canyie/pine/Pine;->cloneExtras(J)J

    move-result-wide v0

    invoke-static/range {p0 .. p1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    invoke-static/range {p2 .. p3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    invoke-static/range {p4 .. p5}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    filled-new-array {v2, v3, v4, v5}, [Ljava/lang/Object;

    move-result-object v2

    const-string v3, "handleBridge: artMethod=%#x originExtras=%#x extras=%#x sp=%#x"

    invoke-static {v3, v2}, Ltop/canyie/pine/Pine;->log(Ljava/lang/String;[Ljava/lang/Object;)V

    invoke-static/range {p0 .. p1}, Ltop/canyie/pine/Pine;->getHookRecord(J)Ltop/canyie/pine/Pine$HookRecord;

    move-result-object v8

    iget-object v2, v8, Ltop/canyie/pine/Pine$HookRecord;->paramTypesCache:Ljava/lang/Object;

    const/4 v9, 0x0

    const/4 v11, 0x4

    if-nez v2, :cond_b

    iget v2, v8, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    iget-boolean v3, v8, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-nez v3, :cond_0

    add-int/lit8 v2, v2, 0x1

    const/4 v4, 0x1

    const/4 v5, 0x1

    goto :goto_0

    :cond_0
    move v4, v9

    move v5, v4

    :goto_0
    if-eqz v2, :cond_9

    new-array v2, v2, [Z

    if-nez v3, :cond_1

    aput-boolean v9, v2, v9

    :cond_1
    move v3, v9

    move v6, v3

    :goto_1
    iget v7, v8, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-ge v3, v7, :cond_a

    iget-object v7, v8, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    aget-object v7, v7, v3

    sget-object v12, Ljava/lang/Double;->TYPE:Ljava/lang/Class;

    if-ne v7, v12, :cond_2

    const/4 v7, 0x1

    :goto_2
    const/4 v12, 0x1

    goto :goto_3

    :cond_2
    sget-object v12, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    if-ne v7, v12, :cond_3

    move v12, v9

    const/4 v7, 0x1

    goto :goto_3

    :cond_3
    sget-object v12, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    if-ne v7, v12, :cond_4

    move v7, v9

    goto :goto_2

    :cond_4
    move v7, v9

    move v12, v7

    :goto_3
    const/16 v13, 0x8

    if-eqz v7, :cond_5

    if-ge v6, v13, :cond_6

    add-int/lit8 v6, v6, 0x1

    goto :goto_4

    :cond_5
    const/4 v7, 0x7

    if-ge v4, v7, :cond_6

    add-int/lit8 v4, v4, 0x1

    :cond_6
    :goto_4
    if-eqz v12, :cond_7

    goto :goto_5

    :cond_7
    move v13, v11

    :goto_5
    add-int/2addr v5, v13

    iget-boolean v7, v8, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-eqz v7, :cond_8

    aput-boolean v12, v2, v3

    goto :goto_6

    :cond_8
    add-int/lit8 v7, v3, 0x1

    aput-boolean v12, v2, v7

    :goto_6
    add-int/lit8 v3, v3, 0x1

    goto :goto_1

    :cond_9
    sget-object v2, Ltop/canyie/pine/entry/Arm64Entry;->a:[Z

    move v6, v9

    :cond_a
    new-instance v3, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;

    invoke-direct {v3}, Ljava/lang/Object;-><init>()V

    iput v4, v3, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->a:I

    iput v5, v3, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->b:I

    iput v6, v3, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->c:I

    invoke-virtual {v2}, [Z->clone()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, [Z

    iput-object v7, v3, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->d:[Z

    iput-object v3, v8, Ltop/canyie/pine/Pine$HookRecord;->paramTypesCache:Ljava/lang/Object;

    :goto_7
    move v12, v4

    move-object v4, v2

    goto :goto_8

    :cond_b
    iget-object v2, v8, Ltop/canyie/pine/Pine$HookRecord;->paramTypesCache:Ljava/lang/Object;

    check-cast v2, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;

    iget v4, v2, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->a:I

    iget v5, v2, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->b:I

    iget v6, v2, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->c:I

    iget-object v2, v2, Ltop/canyie/pine/entry/Arm64Entry$ParamTypesCache;->d:[Z

    invoke-virtual {v2}, [Z->clone()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, [Z

    goto :goto_7

    :goto_8
    const-wide/16 v13, 0x0

    cmp-long v2, p4, v13

    if-nez v2, :cond_c

    move v5, v9

    :cond_c
    sget-object v2, Ltop/canyie/pine/entry/Arm64Entry;->b:[J

    if-eqz v12, :cond_d

    new-array v3, v12, [J

    move-object v15, v3

    goto :goto_9

    :cond_d
    move-object v15, v2

    :goto_9
    if-eqz v5, :cond_e

    new-array v2, v5, [J

    :cond_e
    move-object v7, v2

    if-eqz v6, :cond_f

    new-array v2, v6, [D

    :goto_a
    move-object v6, v2

    goto :goto_b

    :cond_f
    sget-object v2, Ltop/canyie/pine/entry/Arm64Entry;->c:[D

    goto :goto_a

    :goto_b
    move-wide/from16 v2, p4

    move-object v5, v15

    move-object/from16 p0, v6

    move-object v6, v7

    move-object v10, v7

    move-object/from16 v7, p0

    invoke-static/range {v0 .. v7}, Ltop/canyie/pine/Pine;->getArgsArm64(JJ[Z[J[J[D)V

    if-ge v12, v11, :cond_10

    goto :goto_c

    :cond_10
    const/4 v0, 0x3

    aput-wide p6, v15, v0

    if-ne v12, v11, :cond_11

    goto :goto_c

    :cond_11
    aput-wide p8, v15, v11

    const/4 v0, 0x5

    if-ne v12, v0, :cond_12

    goto :goto_c

    :cond_12
    aput-wide p10, v15, v0

    const/4 v0, 0x6

    if-ne v12, v0, :cond_13

    goto :goto_c

    :cond_13
    aput-wide p12, v15, v0

    :goto_c
    new-instance v0, Ltop/canyie/pine/utils/ThreeTuple;

    move-object/from16 v2, p0

    invoke-direct {v0, v15, v10, v2}, Ltop/canyie/pine/utils/ThreeTuple;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V

    iget-object v1, v0, Ltop/canyie/pine/utils/ThreeTuple;->a:Ljava/lang/Object;

    check-cast v1, [J

    iget-object v2, v0, Ltop/canyie/pine/utils/ThreeTuple;->b:Ljava/lang/Object;

    check-cast v2, [J

    iget-object v0, v0, Ltop/canyie/pine/utils/ThreeTuple;->c:Ljava/lang/Object;

    check-cast v0, [D

    invoke-static {}, Ltop/canyie/pine/Pine;->currentArtThread0()J

    move-result-wide v3

    iget-boolean v5, v8, Ltop/canyie/pine/Pine$HookRecord;->isStatic:Z

    if-eqz v5, :cond_14

    const/4 v5, 0x0

    move v6, v9

    move v7, v6

    goto :goto_d

    :cond_14
    aget-wide v5, v1, v9

    invoke-static {v3, v4, v5, v6}, Ltop/canyie/pine/Pine;->getObject(JJ)Ljava/lang/Object;

    move-result-object v5

    const/4 v6, 0x1

    const/4 v7, 0x1

    :goto_d
    iget v10, v8, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-lez v10, :cond_22

    new-array v10, v10, [Ljava/lang/Object;

    move v11, v9

    move v12, v11

    :goto_e
    iget v15, v8, Ltop/canyie/pine/Pine$HookRecord;->paramNumber:I

    if-ge v11, v15, :cond_23

    iget-object v15, v8, Ltop/canyie/pine/Pine$HookRecord;->paramTypes:[Ljava/lang/Class;

    aget-object v15, v15, v11

    sget-object v9, Ljava/lang/Double;->TYPE:Ljava/lang/Class;

    if-ne v15, v9, :cond_16

    array-length v9, v0

    if-ge v12, v9, :cond_15

    add-int/lit8 v9, v12, 0x1

    aget-wide v15, v0, v12

    invoke-static/range {v15 .. v16}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v12

    move-wide/from16 v18, v13

    goto/16 :goto_14

    :cond_15
    aget-wide v15, v2, v7

    invoke-static/range {v15 .. v16}, Ljava/lang/Double;->longBitsToDouble(J)D

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v9

    move-wide/from16 v18, v13

    :goto_f
    move/from16 v20, v12

    move-object v12, v9

    move/from16 v9, v20

    goto/16 :goto_14

    :cond_16
    sget-object v9, Ljava/lang/Float;->TYPE:Ljava/lang/Class;

    const-wide v16, 0xffffffffL

    if-ne v15, v9, :cond_18

    array-length v9, v0

    if-ge v12, v9, :cond_17

    add-int/lit8 v9, v12, 0x1

    aget-wide v18, v0, v12

    invoke-static/range {v18 .. v19}, Ljava/lang/Double;->doubleToLongBits(D)J

    move-result-wide v18

    move v12, v9

    goto :goto_10

    :cond_17
    aget-wide v18, v2, v7

    :goto_10
    and-long v13, v18, v16

    long-to-int v9, v13

    invoke-static {v9}, Ljava/lang/Float;->intBitsToFloat(I)F

    move-result v9

    invoke-static {v9}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v9

    :goto_11
    const-wide/16 v18, 0x0

    goto :goto_f

    :cond_18
    array-length v9, v1

    if-ge v6, v9, :cond_19

    add-int/lit8 v9, v6, 0x1

    aget-wide v13, v1, v6

    move v6, v9

    goto :goto_12

    :cond_19
    aget-wide v13, v2, v7

    :goto_12
    invoke-virtual {v15}, Ljava/lang/Class;->isPrimitive()Z

    move-result v9

    if-eqz v9, :cond_21

    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    if-ne v15, v9, :cond_1a

    and-long v13, v13, v16

    long-to-int v9, v13

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    goto :goto_11

    :cond_1a
    sget-object v9, Ljava/lang/Long;->TYPE:Ljava/lang/Class;

    if-ne v15, v9, :cond_1b

    invoke-static {v13, v14}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v9

    goto :goto_11

    :cond_1b
    sget-object v9, Ljava/lang/Boolean;->TYPE:Ljava/lang/Class;

    if-ne v15, v9, :cond_1d

    and-long v13, v13, v16

    const-wide/16 v18, 0x0

    cmp-long v9, v13, v18

    if-eqz v9, :cond_1c

    const/4 v9, 0x1

    goto :goto_13

    :cond_1c
    const/4 v9, 0x0

    :goto_13
    invoke-static {v9}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v9

    goto :goto_f

    :cond_1d
    const-wide/16 v18, 0x0

    sget-object v9, Ljava/lang/Short;->TYPE:Ljava/lang/Class;

    const-wide/32 v16, 0xffff

    if-ne v15, v9, :cond_1e

    and-long v13, v13, v16

    long-to-int v9, v13

    int-to-short v9, v9

    invoke-static {v9}, Ljava/lang/Short;->valueOf(S)Ljava/lang/Short;

    move-result-object v9

    goto :goto_f

    :cond_1e
    sget-object v9, Ljava/lang/Character;->TYPE:Ljava/lang/Class;

    if-ne v15, v9, :cond_1f

    and-long v13, v13, v16

    long-to-int v9, v13

    int-to-char v9, v9

    invoke-static {v9}, Ljava/lang/Character;->valueOf(C)Ljava/lang/Character;

    move-result-object v9

    goto/16 :goto_f

    :cond_1f
    sget-object v9, Ljava/lang/Byte;->TYPE:Ljava/lang/Class;

    if-ne v15, v9, :cond_20

    const-wide/16 v15, 0xff

    and-long/2addr v13, v15

    long-to-int v9, v13

    int-to-byte v9, v9

    invoke-static {v9}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v9

    goto/16 :goto_f

    :cond_20
    new-instance v0, Ljava/lang/AssertionError;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Unknown primitive type: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw v0

    :cond_21
    const-wide/16 v18, 0x0

    and-long v13, v13, v16

    invoke-static {v3, v4, v13, v14}, Ltop/canyie/pine/Pine;->getObject(JJ)Ljava/lang/Object;

    move-result-object v9

    goto/16 :goto_f

    :goto_14
    aput-object v12, v10, v11

    add-int/lit8 v7, v7, 0x1

    add-int/lit8 v11, v11, 0x1

    move v12, v9

    move-wide/from16 v13, v18

    const/4 v9, 0x0

    goto/16 :goto_e

    :cond_22
    sget-object v10, Ltop/canyie/pine/Pine;->EMPTY_OBJECT_ARRAY:[Ljava/lang/Object;

    :cond_23
    invoke-static {v8, v5, v10}, Ltop/canyie/pine/Pine;->handleCall(Ltop/canyie/pine/Pine$HookRecord;Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method public static intBridge(JJJJJJJ)I
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result p0

    return p0
.end method

.method public static longBridge(JJJJJJJ)J
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Long;

    invoke-virtual {p0}, Ljava/lang/Long;->longValue()J

    move-result-wide p0

    return-wide p0
.end method

.method public static objectBridge(JJJJJJJ)Ljava/lang/Object;
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static shortBridge(JJJJJJJ)S
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Short;

    invoke-virtual {p0}, Ljava/lang/Short;->shortValue()S

    move-result p0

    return p0
.end method

.method public static voidBridge(JJJJJJJ)V
    .locals 0

    invoke-static/range {p0 .. p13}, Ltop/canyie/pine/entry/Arm64Entry;->handleBridge(JJJJJJJ)Ljava/lang/Object;

    return-void
.end method
